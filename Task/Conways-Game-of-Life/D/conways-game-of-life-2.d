import std.stdio,std.string,std.algorithm,std.typetuple,std.array;

template Iota(int start, int stop) {
    static if (stop <= start)
        alias TypeTuple!() Iota;
    else
        alias TypeTuple!(Iota!(start, stop-1), stop-1) Iota;
}

struct GameOfLife {
  enum Cell : char { dead = ' ', alive = '#' }
  Cell[] grid, newGrid;
  immutable size_t nCols;

  this(int nx, int ny) pure nothrow {
    nCols = nx + 2;
    grid = new typeof(grid)(nCols * (ny + 2));
    newGrid = new typeof(grid)(grid.length);
  }

  void opIndexAssign(in string[] v, in size_t y, in size_t x)
  pure nothrow {
    foreach (nr, row; v)
      foreach (nc, state; row) {
        //grid[(y + nr) * nCols + x + nc] = to!Cell(state);
        assert(state == Cell.dead || state == Cell.alive);
        grid[(y + nr) * nCols + x + nc] = cast(Cell)state;
      }
  }

  void iteration() {
    newGrid[0 .. nCols] = Cell.dead;
    newGrid[$ - nCols .. $] = Cell.dead;
    foreach (nr; 1 .. (newGrid.length / nCols) - 1) {
      newGrid[nr * nCols + 0] = Cell.dead;
      newGrid[nr * nCols + nCols - 1] = Cell.dead;
    }

    foreach (nr; 1 .. (grid.length / nCols) - 1) {
      size_t nr_nCols = nr * nCols;
      foreach (nc; 1 .. nCols - 1) {
        uint count = 0;
        /*static*/ foreach (i; Iota!(-1, 2))
          /*static*/ foreach (j; Iota!(-1, 2))
            static if (i != 0 || j != 0)
              count +=
                (grid[nr_nCols + i * nCols + nc + j] == Cell.alive);
        const a = count == 3 ||
                  (count == 2 && grid[nr_nCols + nc] == Cell.alive);
        newGrid[nr_nCols + nc] = a ? Cell.alive : Cell.dead;
      }
    }

    swap(grid, newGrid);
  }

  string toString() const pure nothrow {
    string ret = "-".replicate(nCols - 1) ~ "\n";
    foreach (nr; 1 .. (grid.length / nCols) - 1)
      ret ~= "|" ~
             cast(char[])grid[nr * nCols + 1 .. nr * nCols + nCols - 1]
             ~ "|\n";
    return ret ~ "-".replicate(nCols - 1);
  }
}

void main() {
  immutable glider1 = ["  #", "# #", " ##"];
  immutable glider2 = ["#  ", "# #", "## "];

  auto uni = GameOfLife(60, 20);
  uni[3,  2] = glider1;
  uni[3, 15] = glider2;
  uni[3, 19] = glider1;
  uni[3, 32] = glider2;
  uni[5, 50] = [" #  #", "#  ", "#   #", "#### "];
  writeln(uni);

  foreach (i; 0 .. 20) {
    uni.iteration();
    writeln(uni);
  }
}
