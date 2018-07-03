Using scripting variables with sqlcmd

We can use variables in our sqlcmd input files or scripts. These scripting variables can be declared in the script itself or passed into the command as a parameter.

To declare and assign a value to a variable in the script

Use the :setvar VariableName Value syntax.

To reference the variable in the script use the following syntax: $(VariableName) where VariableName is the name of your variable.

The following example declares a variable called SelectTable and assigns it the value 'Customers' and then uses this variable in a SELECT statement.

:SETVAR SelectTable Customers

SELECT * FROM $(SelectTable)

The value held in the SelectTable variable replaces the $(SelectTable) reference so that the SELECT statement above would execute as SELECT * FROM Customers.

To declare and assign a value to a variable with a command line parameter

The -v parameter is used to assign variables when using the command line. The following example passes a variable called SelectTable with a value of Customers:

c:\Windows>sqlcmd -i MyScript.sql -v SelectTable = Customers


If you want to pass multiple variables using the command line then simply list the variables with no delimiter between them in following fashion (the example is split onto two lines but should actually be on one line:

c:\Windows>sqlcmd -i MyScript.sql -v
SelectTable = Customers Var2 = 3 Var3 = No
