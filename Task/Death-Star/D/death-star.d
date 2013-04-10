import std.stdio, std.math, std.numeric, std.algorithm;

struct V3 {
    double[3] v;

    @property V3 normalize() pure nothrow const {
        immutable double len = dotProduct(v, v).sqrt();
        //return V3(v[] / len);
        return V3([v[0] / len, v[1] / len, v[2] / len]);
    }

    double dot(in ref V3 y) pure nothrow const {
        immutable double d = dotProduct(v, y.v);
        return d < 0 ? -d : 0;
    }
}


const struct Sphere { double cx, cy, cz, r; }

void drawSphere(in double k, in double ambient, in V3 light) nothrow {
    /** Check if a ray (x,y, -inf).(x, y, inf) hits a sphere; if so,
    return the intersecting z values.  z1 is closer to the eye */
    static bool hitSphere(in ref Sphere sph,
                          in double x0, in double y0,
                          out double z1,
                          out double z2) pure nothrow {
        immutable double x = x0 - sph.cx;
        immutable double y = y0 - sph.cy;
        immutable double zsq = sph.r ^^ 2 - (x ^^ 2 + y ^^ 2);
        if (zsq < 0)
            return false;
        immutable double szsq = sqrt(zsq);
        z1 = sph.cz - szsq;
        z2 = sph.cz + szsq;
        return true;
    }

    enum string shades = ".:!*oe&#%@";
    // positive and negative spheres
    immutable pos = Sphere(20, 20, 0, 20);
    immutable neg = Sphere(1, 1, -6, 20);

    foreach (int i; cast(int)floor(pos.cy - pos.r) ..
                    cast(int)ceil(pos.cy + pos.r) + 1) {
        immutable double y = i + 0.5;
        jloop:
        foreach (int j; cast(int)floor(pos.cx - 2 * pos.r) ..
                        cast(int)ceil(pos.cx + 2 * pos.r) + 1) {
            immutable double x = (j - pos.cx) / 2.0 + 0.5 + pos.cx;

            enum Hit { background, posSphere, negSphere }
            Hit hitResult;
            double zb1, zs2;
            {
                double zb2, zs1;
                if (!hitSphere(pos, x, y, zb1, zb2)) {
                    // Ray lands in blank space, draw bg
                    hitResult = Hit.background;
                } else if (!hitSphere(neg, x, y, zs1, zs2)) {
                    // Ray hits pos sphere but not neg one,
                    // draw pos sphere surface
                    hitResult = Hit.posSphere;
                } else if (zs1 > zb1) {
                    // ray hits both, but pos front surface is closer
                    hitResult = Hit.posSphere;
                } else if (zs2 > zb2) {
                    // pos sphere surface is inside neg sphere,
                    // show bg
                    hitResult = Hit.background;
                } else if (zs2 > zb1) {
                    // Back surface on neg sphere is inside pos
                    // sphere, the only place where neg sphere
                    // surface will be shown
                    hitResult = Hit.negSphere;
                } else {
                    hitResult = Hit.posSphere;
                }
            }

            V3 vec_;
            final switch (hitResult) {
                case Hit.background:
                    putchar(' ');
                    continue jloop;
                case Hit.posSphere:
                    vec_ = V3([x - pos.cx, y - pos.cy, zb1 - pos.cz]);
                    break;
                case Hit.negSphere:
                    vec_ = V3([neg.cx - x, neg.cy - y, neg.cz - zs2]);
                    break;
            }
            immutable V3 nvec = vec_.normalize;

            immutable double b = light.dot(nvec) ^^ k + ambient;
            int intensity = cast(int)((1 - b) * shades.length);
            intensity = min(shades.length, max(0, intensity));
            putchar(shades[intensity]);
        }

        putchar('\n');
    }
}


void main() {
    enum light = V3([-50, 30, 50]).normalize;
    drawSphere(2, 0.5, light);
}
