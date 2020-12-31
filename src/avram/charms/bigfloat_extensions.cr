struct BigFloat
  def self.adapter
    Lucky
  end

  module Lucky
    alias ColumnType = BigFloat
    include Avram::Type

    def from_db!(value : BigFloat)
      value
    end

    def from_db!(value : PG::Numeric)
      value.to_big_f
    end

    def parse(value : BigFloat)
      SuccessfulCast(BigFloat).new(value)
    end

    def parse(values : Array(BigFloat))
      SuccessfulCast(Array(BigFloat)).new values
    end

    def parse(value : PG::Numeric)
      SuccessfulCast(BigFloat).new(value.to_big_f)
    end

    def parse(values : Array(PG::Numeric))
      SuccessfulCast(Array(BigFloat)).new values.map(&.to_big_f)
    end

    def parse(value : String)
      SuccessfulCast(BigFloat).new value.to_big_f
    rescue ArgumentError
      FailedCast.new
    end

    def parse(value : Int32)
      SuccessfulCast(BigFloat).new value.to_big_f
    end

    def parse(value : Int64)
      SuccessfulCast(BigFloat).new value.to_big_f
    end

    def to_db(value : BigFloat)
      value.to_s
    end

    def to_db(values : Array(BigFloat))
      PQ::Param.encode_array(values)
    end

    class Criteria(T, V) < Avram::Criteria(T, V)
      include Avram::BetweenCriteria(T, V)

      def select_sum : BigFloat?
        if sum = super
          sum.as(PG::Numeric).to_big_f
        end
      end

      def select_sum! : BigFloat
        select_sum || 0_f64
      end
    end
  end
end
