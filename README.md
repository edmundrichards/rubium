
Rubium
=======

## DESCRIPTION

Rubium is a CSS verification utility for web developers


## INSTALLATION

### GitHub

    $ git clone git://github.com/edmundrichards/rubium.git
    $ cd rubium/src


## USAGE

Use rubium.rb as a utility. Supply command line arguments to build actionable selenium tests.

    ruby rubium.rb -u "http://www.twitter.com" -q "body #doc #page-outer" -s "position"
    >> Getting value for $('body #doc #page-outer').css('position')
    >> current static
    >> total time 2.949339
      
Use `ruby rubium.rb --help` for detailed usage instructions.


## EXAMPLES

These are simple examples that show how rubium can retain the calculated CSS style on a specific DOM node. These type of tests are really helpful in particular development situations where more than one developer may unfortunantley declare different style on the same element in the DOM: Say two developers are extending an existing widget for the development of a new widget. Each developer may restyle the existing widget without the neccessary namespacing. When both of the new widgets get loaded on the same page, you can use this utility to view the definitive calculated style that is taking effect. Silly developers :)

Single test

    ruby rubium.rb -u "http://www.twitter.com" -q "body #doc #page-outer" -s "position"
    >> Getting value for $('body #doc #page-outer').css('position')
    >> current static
    >> total time 2.949339

Multiple tests

    ruby rubium.rb -u "http://www.twitter.com" -q "body #doc #page-outer .front-container","body #doc #page-outer #page-container" -s "position","height","width"
    >> Getting value for $('body #doc #page-outer .front-container').css('position')
    >> current absolute
    >> Getting value for $('body #doc #page-outer .front-container').css('height')
    >> current 750px
    >> Getting value for $('body #doc #page-outer .front-container').css('width')
    >> current 978px
    >> Getting value for $('body #doc #page-outer #page-container').css('position')
    >> current relative
    >> Getting value for $('body #doc #page-outer #page-container').css('height')
    >> current 879px
    >> Getting value for $('body #doc #page-outer #page-container').css('width')
    >> current 837px
    >> total time 7.689255

