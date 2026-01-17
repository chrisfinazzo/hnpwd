all: test gen tidy

test:
	sbcl --noinform --eval "(defvar *quit* t)" --load test.lisp --quit

gen:
	sbcl --noinform --load gen.lisp --quit

tidy:
	tidy -q -e web/index.html

loop:
	while true; do make gen; sleep 5; done

pub: gen co gh cb

pr:
	(git show-ref pr && git branch -d pr) || :
	@echo; echo 'Enter remote URL <space> branch to fetch:'
	@read answer && git fetch $$answer:pr; echo
	git log -n 2 pr
	git diff pr^!

co:
	git add -p
	@echo 'Type Enter to commit, Ctrl + C to cancel.'; read
	git commit

mirror: cb cbpg

# Publish to GitHub Pages.
ghpg:
	sbcl --script gen.lisp
	cd web/ && git init
	cd web/ && git add .
	cd web/ && git config user.name 'Continuous Deployment'
	cd web/ && git config user.email 'cd@localhost'
	cd web/ && git commit -m 'Generate website'
	cd web/ && git branch -M main
	cd web/ && git branch -a
	cd web/ && git remote add origin git@github.com:hnpwd/hnpwd.github.io.git
	cd web/ && git push -f origin main

# Publish to Codeberg Pages.
cbpg:
	rm -rf /tmp/pages/
	cd /tmp/ && git clone git@github.com:hnpwd/hnpwd.github.io.git pages
	cd /tmp/pages && git remote add cbpg git@codeberg.org:hnpwd/pages.git
	cd /tmp/pages && git push -f cbpg main

# Mirror source code to Codeberg.
cb:
	git remote remove cb || :
	git remote add cb git@codeberg.org:hnpwd/hnpwd.git
	git push cb main
	git push cb --tags

sshkey:
	ssh-keygen -t ed25519 -f ghcd
	mv ghcd ghcd.key
