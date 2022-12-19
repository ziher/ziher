class FiscalYear
    include ActiveModel::Validations

    validates_presence_of :year

    attr_accessor :year
    def initialize(year)
      @year = year
    end

    def journals
        Journals.where(year: self.year)
    end

    def grants
      Grant.get_by_year(self.year)
    end
end
