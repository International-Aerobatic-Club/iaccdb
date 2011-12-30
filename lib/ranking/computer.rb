module Ranking
  class Computer
    # compute rankings for values
    # values is an array of values for each of the alternatives
    # returns an array of rankings r for each of the alternatives, where
    # r[i] has the count of indices j where
    # values[i] < values[j], plus one
    # example:
    # values = [81, 82, 81, 94, 66, 63]
    # returns [3, 2, 3, 1, 5, 6]
    def self.ranks_for(values)
      r = Array.new(values.length, 1)
      (0 ... values.length).each do |i|
        (i + 1 ... values.length).each do |j|
          if (values[i] && values[j])
            r[i] += 1 if values[i] < values[j]
            r[j] += 1 if values[j] < values[i]
          end
        end
      end
      r
    end

    # compute rank matrix from value matrix
    # matrix is an array of arrays[row][column]
    # each row array contains an array of values for each alternative
    # rows are values given each alternative by one evaluator
    # columns are values given one alternative by each evaluator
    # the matrix must be rectangular-- each row matrix[row] must be
    # an array of length equal to (or greater than) the first row
    # returns a matrix of rankings where the columns r[i][c] contain ranks
    # r[i][c] has the count of indices j where
    # values[i][c] < values[j][c], plus one
    def self.rank_matrix(matrix)
      colCt = matrix[0].length
      rowCt = matrix.length
      r = Array.new(rowCt)
      (0 ... rowCt).each { |i| r[i] = Array.new(colCt, 1) }
      (0 ... colCt).each do |c|
        (0 ... rowCt).each do |i|
          (i + 1 ... rowCt).each do |j|
            if matrix[i][c] && matrix[j][c]
              r[i][c] += 1 if (matrix[i][c] < matrix[j][c])
              r[j][c] += 1 if (matrix[j][c] < matrix[i][c])
            end
          end
        end
      end
      r
    end
  end
end
