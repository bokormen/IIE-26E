# Denne funksjonen skriver ut hovedmenyen frem til noen velger avlsutt i menyen
function Start-ExchangeAdminstrasjon() {
    # While l�kken kj�rer frem til det kj�res en break med taggen exchangeAdministrasjon
    :exchangeAdministrasjon while ($true) {
        # While l�kken kj�rer frem til det kj�res en break med taggen fortsettAdministrering
        # Denne er her slik at en bruker kan avslutte en uproduktiv leting etter en bruker blant annet, uten � m�tte starte funksjonen som starter fjernadminstrering av exchange p� nytt
        :fortsettAdministrering while($true) {
            # �pner hovedmenyen
            Get-Hovedmeny
        }
    }
}