Red Faction Reversed
====================

Repository contains reverse engineered Red Faction binary file formats and network protocol specifications.

How to use KSY files
--------------------
KSY files contains file format specification in domain driven language named Kaitai Struct. KSY files can be converted into parsers in multiple languages (C++, C#, Java, etc.). See Kaitai Struct website: https://kaitai.io/

You can test the specification live live by providing a real file (e.g. RFL) and parsing it in Kaitai on-line IDE: https://ide.kaitai.io/

How to use C++ header files
---------------------------
Some formats/protocols are described using C++ headers. You can use constants from them directly. Most of RF formats use variable length structures (e.g. strings, arrays). C++ structures cannot contain variable-length fields so structures requiring such feature are commented-out or if'ed out and written using pseudo-C++. In this case programmer has to create parsing logic manually.

IDA
---
`IDA` directory contains IDA Free 8.2 databases exported to IDC format. To use them import an exe file into IDA Free (`RF.exe` or `RED.exe`) and then use `File->Script file...` tool to import a matching IDC file.

Databases contain human-readable definitions for most functions and types used by RF engine. Definitions are based on debug info in early PS2 RF build + some guessing.

License
-------
The GPL-3 license. See LICENSE.txt.
