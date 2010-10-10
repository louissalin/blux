# Blux
Blux is an offline blog manager that lets you manage your blog posts offline and publish them to any blog engine that supports AtomPub. 

## install
gem install Blux

That's it!

## configuration
Blux reads its configuration info from  ~/.bluxrc. The first time you run blux, it will create this file for you, but will immediately complain about missing configuration items. Use the following configuration example for a Wordpress blog and edit each line as needed:

	editor: vim
	html_converter: ruby textile_to_html.rb
	
	blog: myWordpressBlog
	author_name: Mr. Author
	user_name: my_user_id
	password: my_password

**editor:** this is the shell command that will be executed to launch your editor of choice

**html_converter:** Blux will use this shell command to convert your blog draft to html. In the example above, Blux will use the textile_to_html.rb script, which is included with this application. The script will transform your post, written in the textile markup language, and convert it to html.

**blog:** this is your Wordpress blog ID

**author_name:** the name of the author

**user_name:** your Wordpress user name that Blux will use to publish your posts

**password:** your Wordpress password

## Blux from command line

Blux is a command line tool that currently operates without a GUI of any sort. Here are a few of the commands you can use:

> 	$ blux.rb -n  (--new)

this command launches your text editor. As soon as you quit the editor, it will create a draft in the Blux draft folder in ~/.blux/draft

> 	$ blux.rb -s (--set) --latest title "a title"

this command sets a title on the latest created draft

> 	$ blux.rb -s -f draft1.23 title "a title"

the -f <filename> option can be used to tell Blux to operate on a specific draft by use the draft's filename (without the path)

> 	$ blux.rb -s --title "old title" title "new title"

use --title <title> to tell Blux to operate on a draft with a specific title. In this case, blux will change the title of the "old title" draft to "new title"

> 	$ blux.rb -l (--list)

this command will list all your drafts, showing each draft by filename

> 	$ blux.rb -l --with-preview

use --with-preview when you want to show a small snippet of each draft during the listing

> 	$ blux.rb -l --details -f draft1.23

user --details to see each draft filename followed by the drafts attributes in JSON format when listing

> 	$ blux.rb -o (--out) -f draft1.23

this command will output the content of your draft to stdin

> 	$ blux.rb -c (--convert) --latest

this command will invoke the specified converter to convert your post to html

> 	$ blux.rb -e (--edit) --title "title 1"

use this command to edit a draft

> 	$ blux.rb -e -f draft1.23 --verbose

when using the --verbose option, Blux will output a lot of extra information to the screen as it works

## community
feel free to post your comments or questions to the Blux Google group here: blux_manager@googlegroups.com 
