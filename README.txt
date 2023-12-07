how i set up lua:

```
curl -R -O http://www.lua.org/ftp/lua-5.4.6.tar.gz
tar zxf lua-5.4.6.tar.gz
cd lua-5.4.6
make all test
sudo make install
```


how I am testing ast.lua:

```
~/FallQ2023/CSC430/Assignments/a9 ❯ lua -last // syntax: lua  -l(FILENAME)                                                                 
Lua 5.4.6  Copyright (C) 1994-2023 Lua.org, PUC-Rio
> x = NumC(9)
> x.n
9
> x.type
NumC
> z = StrC("hi")
> z.type
StrC
> z.s
hi
> y = IfC(NumC(9), IdC("hi"), StrC("string"))
> print(exprToString(y))
IfC(NumC('9') IdC('hi) StrC('string'))
```
