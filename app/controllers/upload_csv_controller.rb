require 'csv'
require 'set'

WARNINGS = "warnings"
ERRORS = "errors"

class UploadCsvController < ApplicationController
  def index
  end

  def upload
    if params[:commit] == 'Check'
      check()
    elsif params[:commit] == 'Upload'
      upload_file()
    end
  end

  def check
    # open csv file
    @rowarraydisp = open_csv_file()
    prepare_data_and_indexes()

    @journals_hash = {}

    # hash with errors and warnings
    # {row_num => {warning=>warning_type; error=>error_type}}
    @errors  = Array.new(@rowarraydisp.length()-1) {{WARNINGS=>0, ERRORS=>0}}

    @rowarraydisp[1..@rowarraydisp.length()].each_with_index do |row, index|
      journal_id = row[@journal_col_index].to_i
      
      # prepare hash for journal_id
      unless @journals_hash.key?(journal_id)
        @journals_hash[journal_id] = {:rows=>0, :errors=>0, :warnings=>0}
      end
      @journals_hash[journal_id][:rows] += 1

      # ------------ errors and warnings finder ------------
      check_row_and_add_errors(@rowarraydisp[0], row, index)
    end
  end

  def upload_file
    # open csv file
    @rowarraydisp = open_csv_file()
    prepare_data_and_indexes()
    skip_warnings = true # TODO: FROM FORM
    @rowarraydisp[1..@rowarraydisp.length()].each_with_index do |row|
    # @rowarraydisp[1..2].each_with_index do |row|
      errors, warnings = check_row(@rowarraydisp[0], row)
      if errors == 0
        if skip_warnings or warnings == 0
          # Create object
        end
      end
    end
  end

  def open_csv_file
    myfile = params[:upload_csv][:file]
    separator = params[:upload_csv][:separator]
    return rowarraydisp = CSV.read(myfile.path, {:col_sep => separator})
  end

  def prepare_data_and_indexes
    # read declared indexes from form (different column indexes for single ang multi journal)
    @journal_col_index = params[:journal_col_index].to_i

    unit_id = params[:unit_id].to_i
    journaltype_id = params[:journaltype_id].to_i
    @date_format = params[:date_format]
    @user_journals = Journal.find_by_user(current_user)

    # add a column with journal id if doesnt exist (for csv with single journal)
    journals_multi = params[:upload_csv][:journals_multi]
    if journals_multi == "false"
      # read year from csv and find journal id
      unit = Unit.find(unit_id)
      type = JournalType.find(journaltype_id)
      
      @journal_col_index += 1
      @rowarraydisp[0].unshift("Numer książki")
      @rowarraydisp[1..-1].each_with_index do |row, index|
      # @rowarraydisp[1..3].each_with_index do |row, index|

        # catch wrong date error
        # catch not existing journal error
        begin
          journal_year = Date::strptime(@rowarraydisp[index+1][0], @date_format).year
          journal = Journal.find_by_unit_and_year_and_type(unit, journal_year, type)
          row.unshift(journal.id)
        rescue => e
          row.unshift("###")
        end
      end
    end
    
    # add index in first column
    @rowarraydisp[0].unshift("#")
    @rowarraydisp[1..@rowarraydisp.length()].each_with_index do |row, index|
      row.unshift(index)
    end
    @journal_col_index += 1
    
    @date_index = @journal_col_index + 1
    @description_index = @date_index + 1
    @docno_index = @description_index + 1

    # find last expenses column, next one is income
    # hashing {journal_id: {rows, errors}}
    @rowarraydisp[0].each_with_index do |col_name, index|
      logger.debug col_name
      if (col_name == 'Wpływy razem')
        @incomes_sum_index = index
        @expenses_sum_index = @incomes_sum_index + 1
      end
    end

    # incomes next to doc_no
    @incomes_vals_start_index = @docno_index + 1
    # expenses next to sum_expenses and sum_expenses_one_percent
    @expenses_vals_start_index = @expenses_sum_index + 2

    # list incomes categories
    @incomes_categories = Array.new
    @rowarraydisp[0][@incomes_vals_start_index..@incomes_sum_index-1].each do |income_category|
      @incomes_categories.append(income_category)  
    end

    # list expenses categories
    @expenses_categories = Array.new
    @rowarraydisp[0][@expenses_vals_start_index..-1].each do |expense_category|
      @expenses_categories.append(expense_category)  
    end
  end    

  def check_row_and_add_errors(column_names, row, row_index)
    errors, warnings = check_row(column_names, row)
    
    journal_id = row[@journal_col_index].to_i
    @journals_hash[journal_id][:errors] += errors
    @errors[row_index][ERRORS] += errors
    
    @journals_hash[journal_id][:warnings] += warnings
    @errors[row_index][WARNINGS] += warnings
  end
  
  def check_row(column_names, row)
    # ERRORS: 
    # ERROR: journal doesnt exist or user cant manage entries
    # ERROR: user cant manage entries
    # ERROR: journal doesnt exist
    # ERROR: journal is closed
    # ERROR: only 1% column could be negative
    # ERROR: income in category that doesnt exist for journal year

    # ERROR: expense value couldn't be negative
    # ERROR: one percent expense value couldn't be greater than expense value
    # ERROR: expense in category that doesnt exist for journal year
    # WARNINGS:
    # WARNING: expenses doesnt match expenses sum
    # WARNING: incomes doesnt match incomes sum

    journal_id = row[@journal_col_index].to_i
    errors = 0
    warnings = 0
      # ERROR: journal doesnt exist or user cant manage entries
      begin
        journal = Journal.find(journal_id)

        # ERROR: user cant manage entries
        unless @user_journals.include? journal
          errors += 1
        end
        
      rescue => e
        # ERROR: journal doesnt exist
        errors += 1
      end

      # ERROR: journal is closed
      begin
        date = Date::strptime(row[@date_index], @date_format)
        if !journal.is_not_blocked(date)
          errors += 1
        end
      rescue => e
        errors += 1
      end

      if errors > 0
        return errors, warnings
      end

      # ------------- INCOMES AND EXPENSES -------------
      
      # Sum every income
      incomes_sum = 0
      ctgs = Category.find_by_year_and_type(journal.year, false) # incomes categories
      row[@incomes_vals_start_index..@incomes_sum_index-1].each_with_index do |income, index|
        incomes_sum += float_val(income)

        col_name = column_names[@incomes_vals_start_index + index]

        # ERROR: only 1% column could be negative
        if float_val(income) < 0 && col_name != "1%"
          errors += 1
        end

        # ERROR: income in category that doesnt exist for journal year
        if !ctgs.detect { |c| c.name == col_name }
          errors += 1
        end
      end
      
      # WARNING: incomes doesnt match incomes sum
      if incomes_sum != float_val(row[@incomes_sum_index])
        warnings += 1
      end

      # Sum every expense
      expenses_sum = 0
      expenses_one_percent_sum = 0
      ctgs = Category.find_by_year_and_type(journal.year, true) # expenses categories

      column_names[@expenses_vals_start_index..-1].each_slice(2).with_index do |item, index|
        expense_col_index = @expenses_vals_start_index + 2*index
        row_expense_val = float_val(row[expense_col_index])
        row_expense_one_perc_val = float_val(row[expense_col_index + 1])
  
        expenses_sum += row_expense_val
        expenses_one_percent_sum += row_expense_one_perc_val

        # ERROR: expense value couldn't be negative
        if row_expense_val < 0 || row_expense_one_perc_val < 0
          errors += 1
        end

        # ERROR: one percent expense value couldn't be greater than expense value
        if row_expense_val < row_expense_one_perc_val
          errors += 1
        end

        # ERROR: expense in category that doesnt exist for journal year
        if !ctgs.detect { |c| c.name == item[0] }
          errors += 1
        end
      end

      # ERROR: incomes and expenses in one row
      if incomes_sum != 0 && expenses_sum != 0
        errors += 1

      # WARNING: expenses doesnt match expenses sum
      if expenses_sum != float_val(row[@expenses_sum_index])
        warnings += 1
      end


      # ERROR: none incomes and expenses
      elsif incomes_sum== 0 && expenses_sum == 0
        warnings += 1
      
      end
    return errors, warnings
  end

  def float_val(val)
    return val.to_s.gsub(',', '.').to_f
  end
end