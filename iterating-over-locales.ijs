NB. There is an article on the J wiki describing some complicated ways
NB. of iterating over some locales:
NB. <https://code.jsoftware.com/wiki/Studio/Iterating_with_Class_Verbs>
NB. I would do it like this:

NB. some class C
coclass 'C'
    create =: {{ foo =: y }}
    destroy =: {{ codestroy '' }}
    get =: 3 : 'foo'
    set =: 4 : 'foo =: y'
    inc =: 3 : 'foo =: foo + 1'

cocurrent 'base'

NB. some instances
o1 =: 100 conew 'C'
o2 =: 200 conew 'C'
o3 =: 300 conew 'C'

NB. we want to avoid having to do this:
get__o1 ''
get__o2 ''
get__o3 ''

NB. iterating over a group of locales/instances
group =: o1, o2, o3
{{
    for_o. group do. inc__o '' end.
    for_o. group do. echo get__o '' end.
}} ''

NB. cleanup
{{for_o. group do. destroy__o '' end.}}''
conames ''
coerase <'C'
erase 'group o1 o2 o3'
names ''
