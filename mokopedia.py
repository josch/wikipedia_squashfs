#!/usr/bin/python

import gtk
import bz2
import gtkhtml2
import time

class Mokopedia:
    document = gtkhtml2.Document()

    def delete_event(self, widget, event, data=None):
        gtk.main_quit()
        return False

    def __init__(self):
        self.window = gtk.Window(gtk.WINDOW_TOPLEVEL)
        self.window.set_title("Mokopedia")
        self.window.connect("delete_event", self.delete_event)
        self.window.set_border_width(0)
	self.window.set_default_size(480,640)

	main_box = gtk.VBox()

	search_box = gtk.HBox()

	search_entry = gtk.Entry()
	search_box.add(search_entry)

	search_btn = gtk.Button("Search")
	search_btn.connect("clicked", self.search)
	search_box.pack_start(search_btn, False, False, 0)

	#document.connect('request_url', request_url)
	#document.connect('link_clicked', link_clicked)

	self.displayarticle("Alexander_the_Great")

	view = gtkhtml2.View()
	view.set_document(self.document)

	sw = gtk.ScrolledWindow()
	sw.set_policy(gtk.POLICY_AUTOMATIC, gtk.POLICY_ALWAYS)
	sw.add(view)
	
	main_box.pack_start(search_box, False, False, 0)

	main_box.add(sw)
        
        self.window.add(main_box)
        self.window.show_all()

    def search(self, widget):
        print "blubber"

    def displayarticle(self, title):
	self.document.clear()
	self.document.open_stream('text/html')

	before = time.time()
	#f = open(title + ".html.bz2")
	f = open("Alexander_the_Great (another copy).html")
	#self.document.write_stream(bz2.decompress(f.read()))
	self.document.write_stream(f.read())
	f.close()
	print time.time() - before
	self.document.close_stream()

        
def main():
    gtk.gdk.threads_init()
    gtk.gdk.threads_enter() 
    gtk.main()
    gtk.gdk.threads_leave() 
    
       
if (__name__ == '__main__'):
    Mokopedia = Mokopedia()
    main()
