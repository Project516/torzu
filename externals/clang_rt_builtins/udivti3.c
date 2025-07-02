typedef unsigned __int128 tu_int;

tu_int __udivti3(tu_int a, tu_int b)
{
    if (b == 0) {
        // Handle division by zero (could also trigger a fault)
        return 0;
    }

    if (b > a) {
        return 0;
    }

    int shift;
    for (shift = 0;; shift++) {
        if (shift >= 128) {
            break;
        }
        tu_int shifted_b = b << shift;
        if (shifted_b > a || (shifted_b >> shift) != b) {
            break;
        }
    }
    shift--;

    tu_int quotient = 0;
    for (; shift >= 0; shift--) {
        tu_int shifted_b = b << shift;
        if (shifted_b <= a) {
            quotient |= (tu_int) 1 << shift;
            a -= shifted_b;
        }
    }

    return quotient;
}
