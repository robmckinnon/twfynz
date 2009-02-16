class ParentDebate < Debate

  before_validation_on_create :populate_sub_debate

  has_many :sub_debates, :class_name => 'SubDebate',
           :order => 'debate_index',
           :foreign_key => 'debate_id',
           :dependent => :destroy

  def is_parent_with_one_sub_debate?
    sub_debates.size == 1
  end

  def last_debate_index
    sub_debates.last.debate_index
  end
  
  def sub_debate
    sub_debates.first
  end

  def category
    'debate'
  end

  def next_index
    if sub_debates.size == 1
      index.next.next
    else
      index.next
    end
  end

  protected

    def make_url_slug_text
      '' # slugs are set on the sub-debates
    end

    def sub_names= names
      @sub_names = names
    end

    def sub_name= name
      @sub_names = [name]
    end

    def populate_sub_debate type=SubDebate
      if @sub_names
        @sub_names.each_with_index do |sub_name, index|
          sub_debate = type.new :name => sub_name,
              :date => date,
              :publication_status => publication_status,
              :css_class => 'subdebate',
              :debate_index => debate_index + 1 + index,
              :source_url => source_url,
              :hansard_volume => hansard_volume
          sub_debate.debate = self
          self.sub_debates << sub_debate
        end
        @sub_names = nil
      end
    end
end
