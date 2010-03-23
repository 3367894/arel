module Arel
  class Compound
    include Relation

    attr_reader :relation
    delegate :joins, :join?, :inserts, :taken, :skipped, :name, :externalizable?,
             :column_for, :engine, :sources, :locked, :table_alias,
             :to => :relation

    def self.requires(feature = nil)
      @requires ||= nil
      @requires = feature if feature
      @requires
    end

    [:attributes, :wheres, :groupings, :orders, :havings, :projections].each do |operation_name|
      class_eval <<-OPERATION, __FILE__, __LINE__
        def #{operation_name}
          @#{operation_name} ||= relation.#{operation_name}.collect { |o| o.bind(self) }
        end
      OPERATION
    end

    def hash
      @hash ||= :relation.hash
    end

    def eql?(other)
      self == other
    end

    def engine
      requires = self.class.requires
      engine   = relation.engine

      # Temporary check of whether or not the engine supports where.
      engine_handles?(self) ? engine : Memory::Engine.new
    end

  private

    def arguments_from_block(relation, &block)
      block_given?? [yield(relation)] : []
    end
  end
end
