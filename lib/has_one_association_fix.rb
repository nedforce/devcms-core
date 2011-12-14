# This fix is required to prevent the finder SQL from being cached when the owner hasn't been saved yet

module ActiveRecord
  module Associations
    class HasOneAssociation
      def initialize(owner, reflection)
        super
        construct_sql unless owner.new_record?
      end

      private
        def find_target
          construct_sql unless defined?(@finder_sql)
          
          the_target = @reflection.klass.find(:first,
            :conditions => @finder_sql,
            :select     => @reflection.options[:select],
            :order      => @reflection.options[:order], 
            :include    => @reflection.options[:include],
            :readonly   => @reflection.options[:readonly]
          )
          set_inverse_instance(the_target, @owner)
          the_target
        end
    end
  end
end
