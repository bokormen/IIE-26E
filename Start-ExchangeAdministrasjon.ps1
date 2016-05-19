# Denne funksjonen skriver ut hovedmenyen frem til noen velger avlsutt i menyen
function Start-ExchangeAdminstrasjon() {
    # While løkken kjører frem til det kjøres en break med taggen exchangeAdministrasjon
    :exchangeAdministrasjon while ($true) {
        # While løkken kjører frem til det kjøres en break med taggen fortsettAdministrering
        # Denne er her slik at en bruker kan avslutte en uproduktiv leting etter en bruker blant annet, uten å måtte starte funksjonen som starter fjernadminstrering av exchange på nytt
        :fortsettAdministrering while($true) {
            # Åpner hovedmenyen
            Get-Hovedmeny
        }
    }
}