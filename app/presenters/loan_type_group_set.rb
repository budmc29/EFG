class LoanTypeGroupSet
  class Group
    def self.for(object_names)
      Class.new(self) do
        define_method(object_names) do
          objects
        end
      end
    end

    def initialize(name, &condition)
      @name = name
      @condition = condition
      @objects = []
    end

    attr_reader :name

    def <<(object)
      objects << object
    end

    def match(object)
      condition.call(object)
    end

    private
    attr_reader :objects, :condition
  end

  include Enumerable

  def self.filter(objects_name, objects, &mapper)
    set = new(objects_name)
    set.filter(objects, &mapper)
    set
  end

  def initialize(objects_name)
    @objects_name = objects_name
  end

  def each(&block)
    groups.each(&block)
  end

  def groups
    @groups ||= begin
      groups = []

      groups << group_type.new('Legacy SFLG Loans') {|loan| loan.legacy_loan? }
      groups << group_type.new('SFLG Loans') {|loan| loan.sflg? }

      Phase.all.each do |phase|
        # Compare ids here to avoid doing an extra join.
        groups << group_type.new("EFG Loans – #{phase.name}") {|loan| loan.efg_loan? && loan.lending_limit.phase_id == phase.id }
      end

      groups << group_type.new('EFG Loans – Unknown Phase') {|loan| loan.efg_loan? }

      groups.freeze
    end
  end

  def filter(objects, &mapper)
    objects.each do |object|
      if mapper
        loan = mapper.call(object)
      else
        loan = object
      end

      groups.each do |group, filter|
        if group.match(loan)
          group << object
          break
        end
      end
    end
  end

  protected
  attr_reader :objects_name

  def group_type
    @group_type ||= Group.for(objects_name)
  end
end
