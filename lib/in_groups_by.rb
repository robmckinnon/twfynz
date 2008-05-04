class Array

  # Group elements into individual array's by the result of a block
  # Similar to the in_groups_of function.
  # NOTE: assumes array is already ordered/sorted by group !!
  def in_groups_by
    curr=nil.class
    result=[]
    each do |element|
       group=yield(element) # Get grouping value
       result << [] if curr != group # if not same, start a new array
       curr = group
       result[-1] << element
    end
    result
  end

end
