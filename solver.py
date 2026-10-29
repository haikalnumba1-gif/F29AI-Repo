import sys
import time
import csv

class Sudoku_Solver:
    def __init__(self, filename):
        """initialise the solver with input file and metric counters"""
        self.grid = self.load_puzzle(filename)  # loads 9 x 9 grid from input file
        self.search_steps = 0                   #track total recursive function calls
        self.backtracks = 0                     #track how many times dead-ends are met, causing backtracking
        self.execution_time = 0.0               #tracks time taken to solve puzzle in milliseconds

    def load_puzzle(self, filename):
        """read the 9 x 9 grid from .txt or .csv file"""
        grid = []       #create empty list to store 9 rows of the grid

        with open(filename, 'r') as f:      #open file f in read-only mode 
            if filename.endswith('.csv'):   #if file ends with .csv then parse line using csv.reader
                reader = csv.reader(f)
                for row in reader:
                    if row: #skip any empty lines
                        #turns the text string from the CSV row into integer value, produce a
                        #list of 9 numbers, and append to grid list
                        grid.append([int(val.strip()) for val in row])
            else:
                for line in f: #for .txt files, split lines by spaces
                    line = line.strip() #remove empty spaces
                    if line: #skip any empty lines
                        #convert digits into integers and add as a row to grid list
                        grid.append([int(val) for val in line.split()])

        #validate if the grid is 9 x 9
        if len(grid) != 9 or any(len(row) != 9 for row in grid):
            raise ValueError("Puzzle must be a 9 x 9 grid")
        return grid #return sudoku grid

    def print_grid(self, grid=None):
        """print sudoku grid as readable format"""
        if grid is None:
            grid = self.grid

        print("+-------+-------+-------+") #top border of 9 x 9 grid
        for r in range(9): #loop thouch each row index
            row_str = "| " #start every row with a border
            for c in range (9): #loop throuch each column index
                val = grid[r][c] #get value at row r and column c
                #print 0 as a dot, otherwise print value
                display_val = '.' if val == 0 else str(val)
                row_str += display_val + " " #add value to row string with a space

                if (c + 1) % 3 == 0: #if column reaches 3 then add divider
                    row_str += "| "
            print(row_str) # print the whole completed row

            if (r + 1) % 3 == 0: #if row reaches 3 then add divider
                print("+-------+-------+-------+")

    def is_valid(self, row, col, val):
        """check if placing val at grid[row][col] satisfies CSP constraints"""
        #row constraint: check if digit val isn't already in this row
        for c in range(9): #moving across all 9 columns in that row
            if self.grid[row][c] == val:
                return False
            #if val already exists in this row, return False

        #column constraint: check if val isn't already in this column
        for r in range(9): #moving down all 9 rows in this column
            if self.grid[r][col] == val:
                return False
            #if val already exists in this col then return False

        #sub-grid constraint: check that digit val isn't already in the same 3 x 3 sub-grid
        #intger division by 3 to find the top left corner of sub-grid
        start_row, start_col = 3 * (row // 3), 3 * (col // 3)
        for r in range(start_row, start_row + 3): #go through all 3 rows in sub-grid
            for c in range(start_col, start_col + 3): #go through all 3 columns in sub-grid
                if self.grid[r][c] == val:
                    return False
                #if Val already exists in sub-grid, return false

        return True #if satisy all constraints, assignment is valid

    def get_valid_domain(self, row, col):
        """return a list of valid digits 1 - 9 for an empty cell"""
        #test digits 1 - 9 with is_Valid() and keep only valid ones
        return [val for val in range(1, 10) if self.is_valid(row, col, val)]

    def select_mrv_variable(self):
        """MRV heuristic: find the empty cell with the fewest remaining valid value"""
        min_remaining = 10 #start with value greater than max domain size 9
        best_cell = None   #store (row, col, domain_list) of best cell found

        #scan all 81 cells on the grid
        for r in range(9):
            for c in range(9):
                if self.grid[r][c] == 0: #search for empty cells only
                    valid_vals = self.get_valid_domain(r, c) #get valid domain for this empty cell
                    number_of_valid = len(valid_vals) #number of valid values for this cell

                    #if this cell has fewer valid options than previous minimum, update best_cell
                    if number_of_valid < min_remaining:
                        min_remaining = number_of_valid
                        best_cell = (r, c, valid_vals)

                    #fail-first: if an empty cell has no valid values, it's a ded-end
                    #backtrack immedicately without checking rest of the grid
                    if min_remaining == 0:
                        return (r, c, []) #return empty cell with no valid values to trigger backtrack

        return best_cell #return cell with minimum remaining values or none if there's no empty cells

    def solve(self):
        """Solving the Sudoku Puzzle using Backtracking enhanced with MRV heuristic"""
        self.search_steps += 1 #increment step counter

        mrv_selection = self.select_mrv_variable() #select the next variable to assign using MRV

        if mrv_selection is None: #if no empty cells are left, puzzle is solved
            return True

        row, col, valid_vals = mrv_selection #get row and column coordinate and valid values list of selected cell

        #if domain is empty then it's a dead-end so backtrack
        if not valid_vals:
            self.backtracks += 1 #increment each time it backtracks
            return False

        #try each valid value for selected cell
        for val in valid_vals:
            self.grid[row][col] = val #assign value to cell

            if self.solve(): #recursively call solve() to choose next variable
                return True #if puzzle solved, return True to pass back to recursive call

            self.grid[row][col] = 0 #undo assignment (backtrack) if recursive call didn't lead to solution

        self.backtracks += 1 #increment backtrack if all valid values fail
        return False #signal failure

    def run(self):
        """Run the solver and measure execution time"""
        print("Initial Sudoku Puzzle:")
        self.print_grid() #print the intital puzzle

        start_time = time.perf_counter() #record the start time
        solved = self.solve()            #run the solver
        end_time = time.perf_counter()   #record the end time

        self.execution_time = (end_time - start_time) * 1000 #calculate total time taken in ms

        if solved:
            print("\nSolved Sudoku Puzzle")
            self.print_grid() #print the solved puzzle
        else:
            print("\nPuzzle has no solution")

        #print all metrics
        print(f"\nSearch Steps: {self.search_steps}")
        print(f"Number of Backtracks: {self.backtracks}")
        print(f"Execution Time: {self.execution_time:.2f} ms")

if __name__ == "__main__":
    if len(sys.argv) < 2: #command line must have 2 arguments:solver.py and input filename
        print("Please include input filename")
        sys.exit(1)

    filename = sys.argv[1] #get filename from command line
    solver = Sudoku_Solver(filename) #create a solver instance
    solver.run() #start solver