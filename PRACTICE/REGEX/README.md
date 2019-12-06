классная - парсить командную строку с учетов строки

домашка, реализовать регвыр

td - турбо дебаггер - для отладки asm кода


load <bx>
    print_string_with_length bx + 01h, ax
    restore <bx>
    load <bx>
    count_non_space_symbols bx + 09h, 3
    restore <bx>
    load <bx>
    print_string_with_length bx + 09h, ax
    restore <bx>
    print_newline
