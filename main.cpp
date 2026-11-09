// Each function triggers exactly one warning. The comment names the compiler part that reports it.

// Front end (c1xx.dll): appears in the SARIF file.
int frontEndC4189()
{
    int unused = 3; // C4189: local variable is initialized but not referenced
    return 0;
}

// Code generator (c2.dll): missing from the SARIF file.
int backEndC4715(int x)
{
    if (x)
    {
        return 1;
    }
} // C4715: not all control paths return a value

// Code generator (c2.dll): missing from the SARIF file.
int backEndC4717(int x)
{
    return backEndC4717(x); // C4717: recursive on all control paths
}

// Code generator (c2.dll): missing from the SARIF file.
int backEndC4700()
{
    int y;
    return y; // C4700: uninitialized local variable used
}

// Code generator (c2.dll): missing from the SARIF file.
int backEndC4723(int x)
{
    int const zero = 0;
    return x / zero; // C4723: potential divide by 0
}
