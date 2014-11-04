<link href="README.css" rel="stylesheet"></link>

hwk v 0.0.3 
===

NOTE: This is pretty alpha software.  Srsly.  Along with weirdnesses that exist in the code itself, there are
weirdnesses that exist when mixing <span class="latex">L<sup>A</sup>T<sub>E</sub>X</span> and tikz and limited memory
usage of the generic pdflatex tool.

A Ruby based Domain Specific Language for taking a compact homework/assignment description, feeding into a <span class="latex">L<sup>A</sup>T<sub>E</sub>X</span> template for a final, nicely formatted homework output. The template of the output is based on the work of http://www.latextemplates.com/template/programming-coding-assignment 

So, essentially this format is Ruby+<span class="latex">L<sup>A</sup>T<sub>E</sub>X</span>+template -> nice pdf output

There are some utility functions that provide specific useful generators for
<span class="latex">L<sup>A</sup>T<sub>E</sub>X</span> code that looks good and lightens some of the tedious aspects of writing up mathematical
descriptions, technical papers and scientific articles.

Highlights:

  +   Can include code segments into nicely formatted source code presentations

  +   Can include arbitrary images in many formats, including but not limited to eps/pdf/...

  +   Integrates with [TIKZ plotting tools for Matlab](http://www.mathworks.com/matlabcentral/fileexchange/22022-matlab2tikz "matlab2tikz") and <span class="latex">L<sup>A</sup>T<sub>E</sub>X</span>.  You must install the tikz tool separately.

  +   Can generate <span class="latex">L<sup>A</sup>T<sub>E</sub>X</span> segments programmatically.

  +   Bibliography handling through biblio


Installation
---

  To install, place the hwk directory in whatever location you choose via:

    $ cd /destination
    $ git clone https://github.com/colbygk/hwk.git

  Once there, you must add the bin directory to your path (bash/ksh/sh):

    $ export HWK_DIR=/destination/hwk
    $ export PATH=$PATH:$HWK_DIR/bin

  After this, you will be able to use the hwk command

  A useful command is the following alias for returning to a directory that contains
  your current working document/homework (bash):
    alias hwkd="cd \"`hwk active`\""

  Once you have used a command, (hwk open, hwk edit, ...) in a particular directory,
  from that point on, you will be able to use hwkd in other shells to quickly navigate
  to that directory/folder.
  
Usage
---

  From the usage description:

    $ hwk

      usage: [-n name] [open|edit|pdf]
        -n name  Create a new name.hwk file, prepopulated
        mk   Run the latexmk environment. Will monitor .hwk file for
           changes and latexmk will reload pdf *BUGGY!*
        tex  Only create the .tex file
        open   Open local .pdf file based on .hwk file.
        edit   Edit local .hwk file, currenlty only one.
        pdf  Generate and open pdf from local .hwk file.
        hwk  Edit the hwk binary or some other specified library file.
        active   Print out last directory worked in.

### Example workflow
  Creating a document:
    $ hwk -n homework7

  This will create a new 'hwk' file: homework7.hwk
  
  You can edit this file however you like, 'hwk' itself provides a short-cut
  command 'hwk edit' that will look for a .hwk file in the local directory and
  edit it based on whatever EDITOR is set to in the environment and will fall back
  to 'vi' if EDITOR is not set.

  The contents of this new file include the initial header information about the
  homework:
    
    title ""
    due_date DateTime.new(2014,9,9,12,30)
    class_name ""
    class_time ""
    author_name ""
    class_professor ""

  Once changed to:

    title "Homework 7"
    due_date DateTime.new(2014,11,6,11,30)
    class_name "Math 333"
    class_time "11:30am"
    author_name "Me"
    class_professor "Prof Snodgrass"

  Then:

    $ hwk pdf
    Working on f.hwk
    Success!  Reopening file!

  Produces a pdf file with a cover page like: [Example PDF coverpage](example/coverpage.pdf "Cover Page Example" target='cover page example') and then opens the file.

  You can modify which application is used to show the PDF file (defaults to Preview.app),
  set the environment variable HWK_OPEN_APP to a different application, e.g. HWK_OPEN_APP='Skim.app'



### Full Syntax

  Note that the full range of Ruby syntax is usable in the hwk file with some idiosyncrasies, primarily inserting
  two backslashes requires using three in the strings processing of the hwk file, e.g.

    %q( \\\ )

  Will insert '\\\\' in the final <span class="latex">L<sup>A</sup>T<sub>E</sub>X</span> document (i.e. for usage with matrix and table syntax in <span class="latex">L<sup>A</sup>T<sub>E</sub>X</span>).
  This is unavoidable as it is a basic part of how Ruby evaluates Ruby code within a string, single quoted (uninterpreted)
  or double quoted (interpreted).

  For the Ruby/Perl string unfamiliar, the following are equivalent:

    ' ' -> %q( )
    " " -> %Q( )

  The <span class="latex">L<sup>A</sup>T<sub>E</sub>X</span> template will automatically handle pagination. If there are other packages you wish to use as part of the
  <span class="latex">L<sup>A</sup>T<sub>E</sub>X</span> header the command 'header\_configs' will allow this:

    header_configs %q( \usepackage{awesomepackage} )

  Note that the contents of the string are otherwise raw <span class="latex">L<sup>A</sup>T<sub>E</sub>X</span> commands. Ruby
  handles these form of string quotings rather intelligently, counting matching parentheses and allowing for the other
  idioms of %q quotation:

    %q( this that (and the) other )

    %q( This that and here and there
        and over there
      )

    %q/ using different start and stop identifiers /

  The bulk of the remaining commands are centered around *questions* and *sections*, these are handled as block commands
  taking the following block after the command and using it to define question/section numbering automatically.

    question do
      text %q( Answer this. )
      solution %q( Here's the answer. )
    end

  See the example output of this [Example PDF question](example/question.pdf "Question Example" target='question example')
  
  [A slightly more complex example](example/exampl1.hwk "raw hwk format" target='hwk example')

  [A waaaaaay more complex example](example/exampl1.hwk "raw hwk format" target='hwk example')

