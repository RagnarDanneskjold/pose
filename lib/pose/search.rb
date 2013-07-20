module Pose

  # A search operation.
  #
  # Is given a query and search options, and returns the search results.
  class Search

    # @param [Array<Class>] classes The classes to search over.
    # @param [String] query_string The full-text part of the search query.
    # @param options Additional search options:
    #    * where: additional where clauses
    #    * join: additional join clauses
    def initialize classes, query_string, options = {}
      @query = Query.new classes, query_string, options
    end


    # Returns an empty result structure.
    def empty_result query
      {}.tap do |result|
        query.class_names.each do |class_name|
          result[class_name] = []
        end
      end
    end


    # Merges the given posable object ids for a single query word into the given search result.
    def merge_search_result_word_matches result, class_name, ids
      if result.has_key? class_name
        result[class_name] = result[class_name] & ids
      else
        result[class_name] = ids
      end
    end


    def results
      @results ||= search
    end


    def search

      # Get the ids of the results.
      result_classes_and_ids = {}
      @query.query_words.each do |query_word|
        search_classes_and_ids_for_word(query_word, @query).each do |class_name, ids|
          merge_search_result_word_matches result_classes_and_ids, class_name, ids
        end
      end

      # Load the results by id.
      {}.tap do |result|
        result_classes_and_ids.each do |class_name, ids|
          result_class = class_name.constantize

          if ids.size == 0
            # Handle no results.
            result[result_class] = []

          else
            # Here we have results.

            if @query.ids_requested?
              # Ids requested for result.
              result[result_class] = @query.has_limit? ? ids.slice(0, @query.limit) : ids
            else
              # Classes requested for result.
              result[result_class] = result_class.where(id: ids)
              result[result_class] = result[result_class].limit(@query.limit) if @query.has_limit?
            end
          end
        end
      end
    end


    # Returns a hash mapping classes to ids for the a single given word.
    def search_classes_and_ids_for_word word, query
      empty_result(query).tap do |result|
        data = Pose::Assignment.joins(:word) \
                               .select('pose_assignments.posable_id, pose_assignments.posable_type') \
                               .where('pose_words.text LIKE ?', "#{word}%") \
                               .where('pose_assignments.posable_type IN (?)', query.class_names)
        query.joins.each { |join| data = data.joins join }
        query.where.each { |where| puts where ; data = data.where where }
        Pose::Assignment.connection.select_all(data.to_sql).each do |pose_assignment|
          result[pose_assignment['posable_type']] << pose_assignment['posable_id'].to_i
        end
      end
    end


  private

    # @param [ActiveRecord::Relation]
    # @return [ActiveRecord::Relation]
    # TODO: remove?
    def apply_where_on_scope scope
      result = scope.clone
      if options[:where].present?
        options[:where].each { |scope| result = result.where(scope) }
      end
      result
    end
  end
end