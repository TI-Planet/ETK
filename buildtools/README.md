#TI-Nspire Lua Project Builder v0.6 (alpha)
 (C) 2015 - The ETK team,  
 Jim Bauwens, Adrien 'Adriweb' Bertrand

##License
	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>.

#What is this tool?
The TI-Nspire project builder is a tool that allows you to easily build Lua projects for the TI-Nspire that consists of many files.

For this, it's powered by a C-like "include" feature.  
Moreover, the project builder allows for lua syntax customization via custom "defines", as a C-like preprocessor.

The builder will also check every file for syntax errors, and if any, give detailed info on them, their location, etc.  
When all that is done, it will try to build the project with Luna (if that failed, you can always build the output file yourself)

#Features

##Including files
It uses a C-like include system, and including files is as easy as :
```lua
--include "blaap/test.lua"
--include "some/dir/core.lua"
```
The builder works recursively: you can have includes in file you include.

##Syntax extensions via define
The builder now allows you to define constants and macro’s using —define:

```lua
--define "LOL" "'Life of links'"
print("LOL") -- prints Life of links
```

You can also use [Lua patterns](http://www.lua.org/pil/20.2.html). For example, to simulate string indexing you could use the following snippit:

```lua
--define "(%w+)%[%~(%w+)%]" "%1:sub(%2, %2)"
```
This would allow you to do something as
```lua
local myString = "ETK"

for i=1, #myString do
	print(myString[~i]) -- prints each letter
end
```

Examples are available in the `tests` folder.

#Usage:

	./build.lua InputLuaFile OutputTNSFile

_Note: You'll need Lua installed on your computer, and [Luna](http://www.unsads.com/projects/nsptools/downloader/download/release/3/file/38) as well if you want the project builder to make a .tns out of the 'compiled' big lua file (otherwise, just copy/paste it into the script editor)_
