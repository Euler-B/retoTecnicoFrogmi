# automatation for development env
backend:	
	cd Backend/ && bin/rails s 
fronted:
	cd Frontend/ && pnpm dev 

start-dev:	
	make backend&
	make frontend