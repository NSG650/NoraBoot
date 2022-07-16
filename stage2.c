void BpPuts(char *String) {
    static unsigned int PosX = 0;
    static unsigned int PosY = 0;

    while (*String) {
        switch (*String) {
            case '\n':
                PosY++;
                PosX = 0;
                break;
            case '\r':
                PosX = 0;
            default:
                ((unsigned short*)0xB8000 )[ PosX + PosY * 80 ] = *String | 0x1F00;
                PosX++;
                break;
        }
        String++;
    }
}

void _start(void) {
        BpPuts("Hello from Stage 2!");
        for(;;)
                ;
}