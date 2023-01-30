all: son.txt
	
son.txt: mom.txt dad.txt
	cat mom.txt > son.txt
	cat dad.txt >> son.txt # merge the content of mom.txt and dad.txt

mom.txt: grandma.txt
	cat grandma.txt > mom.txt # replace the content with grandma.txt

dad.txt: grandpa.txt
	cat grandma.txt > dad.txt

aunt.txt: grandma.txt
	cat grandma.txt > aunt.txt

uncle.txt: grandpa.txt
	cat grandma.txt > uncle.txt

clean:
	@rm mom.txt dad.txt