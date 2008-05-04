class Module
  def morph_accessor sym, default, class_name
    field = sym.to_s.chomp '='
    attribute = (field == 'name') ? class_name.downcase + '_' + field : field

    code = ""+
      "def #{field}=(val)\n"+
      "  @#{attribute} = val\n"+
      "end\n"+
      "def #{attribute}\n"+
      "  @#{attribute} = #{default} unless @#{attribute}\n"+
      "  @#{attribute}\n"+
      "end\n"
    class_eval code
    attribute
  end

  def add_overridden_methods
    unless methods.include? 'overridden_methods'
      class_eval ""+
        "def add_overridden_method(str)\n"+
        "  @overridden_methods = [] unless @overridden_methods\n"+
        "  @overridden_methods << str\n"+
        "end\n"+
        "def overridden_methods\n"+
        "  @overridden_methods\n"+
        "end\n"
    end
  end
end

module Morph

  def method_missing sym, *args
    if Module.respond_to? sym
      # ignore

    elsif Module.respond_to? sym.to_s.chomp('=').to_sym
      puts "using #{sym.to_s} will override core method"
      self.class.add_overridden_methods
      send(:add_overridden_method, sym.to_s.chomp('='))
      attribute = self.class.morph_accessor sym, default_value, self.class.to_s
      send(sym, *args)

    elsif sym != :overridden_methods
      self.class.morph_accessor sym, default_value, self.class.to_s
      send(sym, *args)
    end
  end

  def my_methods
    methods.delete_if do |m|
      (Module.respond_to?(m) and
          (
           (respond_to?(:overridden_methods) == false) or
           (self.overridden_methods == nil) or
           (self.overridden_methods.include?(m) == false)
          )
      ) or
      m == 'method_missing'        or
      m == 'overridden_methods'    or
      m == 'add_overridden_method' or
      m == 'write_class'           or
      m == 'remove_writers'        or
      m == 'default_value'         or
      m == 'each_pair'             or
      m == 'my_methods'
    end.sort
  end

  def each_pair *args
    my_methods.each do |m|
      data = send m.to_sym
      if m == self.class.to_s.downcase+'_name'
        m = 'name'
      end
      yield m, data
    end
  end

  def remove_writers
    my_methods.each do |method|
      if method[-1..-1] == "="
        self.class.class_eval "remove_method :#{method}"
      end
    end
  end

  def default_value
    'nil'
  end

  def write_class
    c = "class #{self.class.to_s}\n"
    my_methods.reject { |m| m =~ /=\Z/ }.each do |field|
      c += <<-EOC
   def #{field}= value
     @#{field} = value
   end
   def #{field}
     @#{field} = #{default_value} unless @#{field}
     @#{field}
   end
 EOC
    end
    c += "end"
    c
  end
end
