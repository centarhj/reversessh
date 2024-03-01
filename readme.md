# The cemit-softprio reverse-ssh service

## Göteborgs Stadsmiljöförvaltnings implementation

Cemit hade skapate ett skript som startade autossh som root. Av säkerhets skäl så ville vi undvika detta.
Även för att förenkla konfigurationen lite så har installationen förändrats lite från Cemits lösning.  
Lösningen baseras dock helt på cemits ideer.

- Användningen av ett bash-skript i en användarkatalog är ersatt av .ssh/config filen
- hostnamn och portar styrs helt från .ssh/config
- identity file skapas och används i /home/<användarnamn>/.ssh
- 

### Använd befintlig användare, eller skapa en ny användare för reverse-ssh tjänsten

### 
