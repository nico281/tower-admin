module Filterable
  extend ActiveSupport::Concern

  private

  # Apply search filter to a collection
  # Usage: apply_search_filter(@users, params[:search], [:email, :name])
  def apply_search_filter(collection, search_term, searchable_columns)
    return collection if search_term.blank?

    conditions = searchable_columns.map { |column| "#{column} ILIKE ?" }.join(" OR ")
    values = [ search_term ].cycle(searchable_columns.size).map { |term| "%#{term}%" }

    collection.where(conditions, *values)
  end

  # Apply enum filter to a collection
  # Usage: apply_enum_filter(@users, params[:role], :role)
  def apply_enum_filter(collection, filter_value, column_name)
    return collection if filter_value.blank?

    collection.where(column_name => filter_value)
  end

  # Apply association filter to a collection
  # Usage: apply_association_filter(@users, params[:company_id], :company_id)
  def apply_association_filter(collection, filter_value, column_name)
    return collection if filter_value.blank?

    collection.where(column_name => filter_value)
  end

  # Apply pagination to a collection
  # Usage: apply_pagination(@users, params[:page], per_page: 10)
  def apply_pagination(collection, page_param, per_page: 10)
    collection.page(page_param).per(per_page)
  end

  # Complete filtering and pagination workflow
  # Usage: filter_and_paginate(User.all, {
  #   search: { term: params[:search], columns: [:email] },
  #   enums: { role: params[:role] },
  #   associations: { company_id: params[:company_id] },
  #   page: params[:page]
  # })
  def filter_and_paginate(collection, options = {})
    # Apply search filter
    if options[:search]
      collection = apply_search_filter(
        collection,
        options[:search][:term],
        options[:search][:columns]
      )
    end

    # Apply enum filters
    if options[:enums]
      options[:enums].each do |column, value|
        collection = apply_enum_filter(collection, value, column)
      end
    end

    # Apply association filters
    if options[:associations]
      options[:associations].each do |column, value|
        collection = apply_association_filter(collection, value, column)
      end
    end

    # Apply pagination
    apply_pagination(collection, options[:page], per_page: options[:per_page] || 10)
  end
end
