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

License
-------
The GPL-3 license. See LICENSE.txt.
