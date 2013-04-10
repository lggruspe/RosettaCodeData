module bitmap;

import std.stdio, std.array, std.exception, std.string, std.conv;

final class Image(T) {
    static if (__traits(compiles, { auto x = T.black; }))
        T blackColor = T.black;
    else
        T blackColor = T.init;

    T[] image;
    private size_t nx_, ny_;

    this(in int nxx=0, in int nyy=0, in bool inizialize=true)
    pure nothrow {
        allocate(nxx, nyy, inizialize);
    }

    void allocate(in int nxx=0, in int nyy=0, in bool inizialize=true)
    pure nothrow in {
        assert(nxx >= 0 && nyy >= 0);
    } body {
        this.nx_ = nxx;
        this.ny_ = nyy;
        if (nxx * nyy > 0) {
            if (inizialize)
                image.length = nxx * nyy;
            else // Optimization.
                image = minimallyInitializedArray!(typeof(image))
                                                  (nxx * nyy);
        }
    }

    static Image fromData(T[] data, in size_t nxx=0, in size_t nyy=0)
    pure nothrow in {
        assert(nxx >= 0 && nyy >= 0 && data.length == nxx * nyy);
    } body {
        auto result = new Image();
        result.image = data;
        result.nx_ = nxx;
        result.ny_ = nyy;
        return result;
    }

    @property size_t nx() const pure nothrow { return nx_; }
    @property size_t ny() const pure nothrow { return ny_; }

    ref T opIndex(in size_t x, in size_t y) pure nothrow
    in {
        assert(x < nx_ && y < ny_);
    } body {
        return image[x + y * nx_];
    }

    T opIndex(in size_t x, in size_t y) const pure nothrow
    in {
        assert(x < nx_ && y < ny_);
    } body {
        return image[x + y * nx_];
    }

    T opIndexAssign(in T color, in size_t x, in size_t y) pure nothrow
    in {
        assert(x < nx_ && y < ny_);
    } body {
        return image[x + y * nx_] = color;
    }

    void opIndexUnary(string op)(in size_t x, in size_t y) pure nothrow
    if (op == "++" || op == "--") in {
        assert(x < nx_ && y < ny_);
    } body {
        mixin("image[x + y * nx_] " ~ op ~ ";");
    }

    void clear(in T color=blackColor) pure nothrow {
        image[] = color;
    }

    /// The axis origin is at the top left.
    void textualShow() const {
        size_t i = 0;
        foreach (immutable y; 0 .. ny_) {
            foreach (immutable x; 0 .. nx_)
                putchar(image[i++] == blackColor ? '#' : '.');
            putchar('\n');
        }
    }
}


struct RGB {
    ubyte r, g, b;
    enum black = RGB();
    enum white = RGB(255, 255, 255);
}


Image!RGB loadPPM6(Image!RGB img, in string fileName) {
    if (img is null)
        img = new Image!RGB();
    auto f = File(fileName, "rb");
    enforce(f.readln().strip() == "P6");
    string line;
    do {
        line = f.readln();
    } while (line.length && line[0] == '#'); // Skip comments.
    const size = line.split();
    enforce(size.length == 2);
    img.allocate(size[0].to!uint(), size[1].to!uint());
    enforce(f.readln().strip() == "255");
    auto l = new ubyte[img.nx * 3];
    size_t i = 0;
    foreach (immutable y; 0 .. img.ny) {
        f.rawRead!ubyte(l);
        foreach (immutable x; 0 .. img.nx)
            img.image[i++] = RGB(l[x*3], l[x*3 + 1], l[x*3 + 2]);
    }
    return img;
}


void savePPM6(in Image!RGB img, in string fileName)
in {
    assert(img !is null);
    assert(img.nx > 0 && img.nx > 0);
} body {
    auto f = File(fileName, "wb");
    f.writefln("P6\n%d %d\n255", img.nx, img.ny);
    size_t i = 0;
    foreach (immutable y; 0 .. img.ny)
        foreach (immutable x; 0 .. img.nx) {
            immutable p = img.image[i++];
            f.write(cast(char)p.r, cast(char)p.g, cast(char)p.b);
        }
}

version (bitmap_main) {
    void main() {
        auto img = new Image!RGB(30, 10);
        img[4, 5] = RGB.white;
        img.textualShow();
    }
}
