/*----------------------------------------------------------------------
 |>>> Class Command
 +-----------------------------------------------------------------------
 | Purpose: Representation of a command parsed from the from the input
 |          text file into a form useable for execution thereafter. See
 |          the State Variables description for more/important info. Note
 |          that a 'toConsole()' function is available to print contents.
 +-----------------------------------------------------------------------
 | Variables:
 | > char id:    ID of commmand to execute as specified in the project 2 
 |               spec. Acceptable values are:
 |                 ['Q']=[QT Area] , ['i']=[Insert] , ['d']=[Delete]
 |                 ['r']=[Report]  , ['c']=[Count]  , ['e']=[Empty] 
 | > int[] args: integer arguments of command s.t. 3 lengths possible:
 |                 |args|=1-> QT Area (i.e. [255])
 |                 |args|=2-> Insert | Delete (i.e. [24,50])
 |                 |args|=4-> Report | Count | Empty (i.e. [6,24,50,516])
 +-----------------------------------------------------------------------
 | Version: > MM/DD/YY - Original <xor> [List of Changes]
 +---------------------------------------------------------------------*/
class Command {
  char id;
  int[] args;
  String comment;

  public Command(char i, int[] a) {
    id = i; 
    args = a;
  }

  public Command(char i, String cmt) {      //second constructor especially for the comment command
    id = i;
    comment = cmt;
  }

  public void toConsole() {   
    String argString = "";
    for (int i=0; i<args.length; i++) {
      argString += str(args[i]);   
      if (i!=args.length-1) {
        argString += " ";
      }
    }      
    println("Command: ID=["+id+"] with args=["+argString+"]");
  }
}


/*----------------------------------------------------------------------
 |>>> Function PrintCommands 
 +-----------------------------------------------------------------------
 | Purpose: Given a list of Command objects, this function prints them to
 |          the console one-by-one via their 'toConsole()' function.
 +---------------------------------------------------------------------*/
void PrintCommands(Command[] c) {
  for (int i=0; i<c.length; i++) {
    c[i].toConsole();
  }
}


/*----------------------------------------------------------------------
 |>>> Function getInput 
 +-----------------------------------------------------------------------
 | Purpose: Given a valid filename, calls Processing's 'loadStrings(...)'
 |          function, which returns the input text file as an array of
 |          Strings s.t. each member encompasses a single line thereof.
 |          Used in the call to parseCommands as seen in the demo code.
 +---------------------------------------------------------------------*/
String [] getInput(String filename) {
  return loadStrings(filename);
}


/*----------------------------------------------------------------------
 |>>> Function strArgsToInts 
 +-----------------------------------------------------------------------
 | Purpose: Given an input array of strings, returns an int array of the
 |          input as int values via int casting. Used by the parser code
 |          to turn string args into coordinate int values thereof.
 +---------------------------------------------------------------------*/
int[] strArgsToInts(String[] args) {
  int[] ret = new int[args.length];  
  for (int i=0; i<args.length; i++) {
    ret[i] = int(args[i]);
  }  
  return ret;
}


/*----------------------------------------------------------------------
 |>>> Function parseCommands 
 +-----------------------------------------------------------------------
 | Purpose: Given a string array corresponding to the lines of the input
 |          text file, this function will parse them into Command objects
 |          for which the array of parsed commands representing the input
 |          is returned to the caller in line order from the input text.
 |          No need to thoroughly explain how this works (though it is
 |          very pleasantly slick!); but you could ask me questions about
 |          it if you're ***that*** curious about the implementation.
 +---------------------------------------------------------------------*/
Command[] parseCommands(String[] strCommands) {
  ArrayList<Command> commands = new ArrayList<Command>();
  char curID = ' ';
  for (int i=0; i<strCommands.length; i++) {  
    curID = char(strCommands[i].charAt(0));
    if (curID == '#') {
      commands.add(new Command(curID, strCommands[i]));
    }
    if (curID != '#') {
      commands.add(new Command(curID, strArgsToInts(subset(split(strCommands[i], " "), 1))));
    }
  }
  return commands.toArray(new Command[0]);
}


/*----------------------------------------------------------------------
 |>>> Function toOutput 
 +-----------------------------------------------------------------------
 | Purpose: This is how you should [will] write information to the output
 |          file. It utilizes the PrintWriter Processing Object, of which
 |          one must be declared as 'writer' and initialized in setup()
 |          before any call to this function is made. Note that function
 |          'flush' is called on every time i.e. redundantly. This is me 
 |          looking out for you: as not flushing the stream and suddenly
 |          closing the window with the 'x' button may cause output text
 |          to NOT be written to the output file. You should not need to
 |          modify this code, nor use anything else to write to output.
 +---------------------------------------------------------------------*/
void toOutput(String s) {
  writer.println(s);
  writer.flush(); // here in case program is closed without hitting 'q' or 'ESC' keys
}


/*----------------------------------------------------------------------
 |>>> Function closeWriter 
 +-----------------------------------------------------------------------
 | Purpose: This function flushes any remaining output to the text file,
 |          then closes the file/PrintWriter object. It should be called
 |          before quitting the program (as demonstrated in this demo)
 +---------------------------------------------------------------------*/
void closeWriter() {
  writer.flush();
  writer.close();
}
