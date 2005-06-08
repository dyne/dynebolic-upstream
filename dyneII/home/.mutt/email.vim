" VIM Macrofile for e-mail

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
" Some settings usefull for vim as external mail-editor
" (c) 2000 Alexander Wagner, Team OS/2 Franken
"
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
" Convert umlauts within original message
" :%s/„/ae/g
" :%s/”/oe/g
" :%s//ue/g
" :%s/Ž/Ae/g
" :%s/™/Oe/g
" :%s/š/Ue/g
" :%s/á/ss/g
"
" Map umlauts to there 7bit equivalent 
" imap „ ae
" imap ” oe
" imap  ue
" imap Ž Ae
" imap š Ue
" imap ™ Oe
" imap á ss
"

set tw=72
set wm=1

" Tab's need to be exapanded in e-mail!
set expandtab
" Source Justify to set mail in blockquote
:so ~/.mutt/justify.vim
"
" switch off backups for e-mail
set nobackup
set syntax=mail
"


" QUAAAAAAAAAAAAAAAA

" checking if the below is right to use
"enable autmatic quote folding
 :set foldmethod=expr
 :set foldexpr=strlen(substitute(substitute(getline(v:lnum),'\\s','',\"g\"),'[^>].*','',''))
"
" unfold last message quotes, keep older quotes folded
" :set foldlevel=1
"
" Don't use modelines in e-mail messages, avoid trojan horses
 setlocal nomodeline
"
" Set 'formatoptions' to break text lines,
" and insert the comment leader ">" when hitting <CR> or using "o".
" setlocal fo+=tcroql

" QUAAAAAAAAAAAAAAAAAA


" iab Yhome       http://www.stellarcom.org/index.html
" iab Yplucker    http://plucker.gnu-designs.com
" iab Yplucker2   http://www.stellarcom.org/plucker/os2_bins/index.html  

" Inserting an ellipsis to indicate deleted text
iab  Yell  [...]
vmap ,yell c[...]<ESC>

" Changing quote style to *the* true quote prefix string "> ":
"
"       Fix Supercite aka PowerQuote (Hi, Andi! :-):
"       before ,kpq:    >   Sven> text
"       after  ,kpq:    > > text
"      ,kpq kill power quote
map ,kpq :1,$s/^> *[a-zA-Z]*>/> >/<C-M>
"
"       Fix various other quote characters:
"      ,fq "fix quoting"
map ,fq :1,$s/^> \([-":}\|][ <C-I>]\)/> > /
"
"  Fix the quoting of "Microsoft Internet E-Mail":
"  The guilty mailer identifies like this:
"  X-Mailer: Microsoft Internet E-Mail/MAPI - 8.0.0.4211
"  
"  And this is how it quotes - with a pseudo header:
"
"  -----Ursprungliche Nachricht-----
"  Von:            NAME [SMTP:ADDRESS]
"  Gesendet am:    Donnerstag,  6. April 2000 12:07
"  An:             NAME
"  Cc:             NAME
"  Betreff:        foobar
"
" And here's how I "fix" this quoting:
" (it makes use of the mappings ",dp" and ",qp"):
  map #fix /^> -----.*-----$<cr>O<esc>j,dp<c-o>dapVG,qp

" Remove eGroups header stuff
  map #ef /-_->$<cr><esc>o<esc>d{ddx
  
"      ,j = join line in commented text
"           (can be used anywhere on the line)
  nmap ,j Vjgq
"
"      ,B = break line at current position *and* join the next line
  nmap ,B r<CR>Vjgq
"     ,hi = "Hi!"        (indicates first reply)
  map ,hi 1G}oHi!<CR><ESC>
  map ,ha 1G}oHallo!<CR><ESC>
"       remove signatures
"
"     ,kqs = kill quoted sig (to remove those damn sigs for replies)
"          goto end-of-buffer, search-backwards for a quoted sigdashes
"          line, ie "^> -- $", and delete unto end-of-paragraph:
  map ,kqs G?^> -- <CR>d}
 
" Move to beginning of text  
:2

