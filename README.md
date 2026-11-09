# MSVC: `/experimental:log` SARIF output misses code generator warnings

`/experimental:log` writes only the diagnostics of the compiler front end (c1xx) into the SARIF file.
Warnings of the code generator (c2), for example C4715, C4717, C4700 and C4723, are printed to the
console but are missing from the SARIF file.

Tools that read the SARIF files instead of the console output, for example CI quality gates, therefore
never see these warnings, although they often point to real bugs (a missing return value, endless
recursion).

## Environment

Same result with all of these:

| Visual Studio | Toolset | `cl.exe` | Tested |
|---|---|---|---|
| 2022 17.14.43 | 14.44.35207 | 19.44.35229 | x64 `/O2`, x64 `/Od`, x86 `/O2` |
| 2026 Insiders [12328.396] | 14.52.37025 | 19.52.37025 | x64 `/O2`, x64 `/Od` |
| 2026 Insiders [12328.396] | 14.53.36919 | 19.53.36919 (PREVIEW) | x64 `/O2`, x64 `/Od`, x86 `/O2` |

## Steps to reproduce

Run `build.bat`. It compiles [main.cpp](main.cpp):

```
cl /nologo /c /W4 /O2 /experimental:log sarif\ main.cpp
```

Every function in `main.cpp` triggers exactly one warning: C4189 from the front end, C4715, C4717,
C4700 and C4723 from the code generator.

## Expected

`sarif\main.sarif` contains a result for each of the five warnings printed on the console.

## Actual

The console shows all five warnings:

```
main.cpp
main.cpp(6): warning C4189: 'unused': local variable is initialized but not referenced
F:\git_projects\msvc-sarif-missing-backend-warnings\main.cpp(23) : warning C4717: 'backEndC4717': recursive on all control paths, function will cause runtime stack overflow
F:\git_projects\msvc-sarif-missing-backend-warnings\main.cpp(17) : warning C4715: 'backEndC4715': not all control paths return a value
F:\git_projects\msvc-sarif-missing-backend-warnings\main.cpp(29) : warning C4700: uninitialized local variable 'y' used
F:\git_projects\msvc-sarif-missing-backend-warnings\main.cpp(36) : warning C4723: potential divide by 0
```

`sarif\main.sarif` contains only C4189:

```json
{
    "version": "2.1.0",
    "$schema": "https://schemastore.azurewebsites.net/schemas/json/sarif-2.1.0-rtm.5.json",
    "runs": [
        {
            "results": [
                {
                    "ruleId": "C4189",
                    "message": {
                        "text": "'unused': local variable is initialized but not referenced"
                    },
                    "locations": [
                        {
                            "physicalLocation": {
                                "artifactLocation": {
                                    "uri": "file:///F:/git_projects/msvc-sarif-missing-backend-warnings/main.cpp"
                                },
                                "region": {
                                    "startLine": 6,
                                    "startColumn": 9
                                }
                            }
                        }
                    ]
                }
            ],
            "tool": {
                "driver": {
                    "name": "MSVC",
                    "shortDescription": {
                        "text": "Microsoft Visual C++ Compiler Warnings/Errors"
                    },
                    "informationUri": "https://docs.microsoft.com/cpp/error-messages/compiler-errors-1/c-cpp-build-errors"
                }
            }
        }
    ]
}
```

The [documentation of the SARIF output](https://learn.microsoft.com/en-us/cpp/build/reference/sarif-output)
does not mention that only front-end diagnostics are included.
