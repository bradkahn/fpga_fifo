// http://wavedrom.com/editor.html

{signal: [
  {name:'rd clk',	wave: 'p......' },
  {name:'rd inc',	wave: '01....0', node:'0123456'},
  {name:'empty',	wave: '0....1.' },
  {name:'data o',	wave: 'xxx345x', data: 'wrd1 wrd2 wrd3', node:'abcdefg' }
],
 edge:['1-2 read init', '1~>c invalid' ,'2-3 1st word', '2~>d wrd 1 avail', '3-4 2nd word', '3~>e wrd 2 avail' ,'4-5 3rd word', '4~>f wrd 3 avail', '5-6 4th word', '5~>g invalid' ],
 head:{
   text:'FIFO Read',
   tick:0,
 },
 foot:{
   text:'Attempting to read 4 words from a FIFO with only 3 words'
 },
 config: { hscale: 3 },
}
