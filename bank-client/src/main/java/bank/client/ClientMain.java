package bank.client;
import bank.interfaces.BanqueRemote;
import bank.entities.CompteCourant;
import java.util.Date;
import java.util.Properties;
import java.util.Scanner;
import javax.naming.Context;
import javax.naming.InitialContext;

public class ClientMain {
    public static void main(String[] args) {
        try {
            Properties props = new Properties();
            props.put(Context.INITIAL_CONTEXT_FACTORY, "org.wildfly.naming.client.WildFlyInitialContextFactory");
            props.put(Context.PROVIDER_URL, "http-remoting://localhost:8080");
            Context ctx = new InitialContext(props);
            
            // JNDI lookup pour Wildfly : ejb:<app-name>/<module-name>/<distinct-name>/<bean-name>!<fully-qualified-remote-interface-name>
            BanqueRemote proxy = (BanqueRemote) ctx.lookup("ejb:/bank-ejb-1.0-SNAPSHOT/BK!bank.interfaces.BanqueRemote");
            
            Scanner scanner = new Scanner(System.in);
            boolean quitter = false;

            System.out.println("==========================================");
            System.out.println("      BIENVENUE DANS VOTRE BANQUE         ");
            System.out.println("==========================================");

            while (!quitter) {
                System.out.println("\nQue souhaitez-vous faire ?");
                System.out.println("1. Créer un nouveau compte");
                System.out.println("2. Faire un versement");
                System.out.println("3. Retirer de l'argent");
                System.out.println("4. Consulter le solde");
                System.out.println("5. Quitter");
                System.out.print("\nVotre choix : ");
                
                String choixStr = scanner.nextLine();
                int choix = -1;
                try {
                    choix = Integer.parseInt(choixStr);
                } catch (NumberFormatException e) {
                    System.out.println("❌ Choix invalide. Veuillez entrer un chiffre.");
                    continue;
                }

                switch (choix) {
                    case 1:
                        System.out.print("Entrez le numéro du nouveau compte (ex: CC4) : ");
                        String nvCompte = scanner.nextLine();
                        System.out.print("Entrez le solde initial : ");
                        double soldeIni = Double.parseDouble(scanner.nextLine());
                        // On suppose que le client 1 existe déjà
                        proxy.ajouterCompte(new CompteCourant(nvCompte, new Date(), soldeIni, 1000), 1L);
                        System.out.println("✅ Le compte " + nvCompte + " a été créé avec succès.");
                        break;
                        
                    case 2:
                        System.out.print("Entrez le numéro de compte à créditer : ");
                        String refVersement = scanner.nextLine();
                        System.out.print("Entrez le montant à verser : ");
                        double montantVersement = Double.parseDouble(scanner.nextLine());
                        proxy.verser(refVersement, montantVersement);
                        System.out.println("✅ Versement de " + montantVersement + "€ effectué.");
                        double soldeApresV = proxy.consulterSolde(refVersement);
                        System.out.println("💳 Nouveau solde : " + soldeApresV + "€");
                        break;
                        
                    case 3:
                        System.out.print("Entrez le numéro de compte à débiter : ");
                        String refRetrait = scanner.nextLine();
                        System.out.print("Entrez le montant à retirer : ");
                        double montantRetrait = Double.parseDouble(scanner.nextLine());
                        try {
                            proxy.retirer(refRetrait, montantRetrait);
                            System.out.println("✅ Retrait de " + montantRetrait + "€ effectué.");
                            double soldeApresR = proxy.consulterSolde(refRetrait);
                            System.out.println("💳 Nouveau solde : " + soldeApresR + "€");
                        } catch (Exception e) {
                            System.out.println("❌ Erreur lors du retrait : " + e.getMessage());
                        }
                        break;
                        
                    case 4:
                        System.out.print("Entrez le numéro de compte à consulter : ");
                        String refConsult = scanner.nextLine();
                        try {
                            double solde = proxy.consulterSolde(refConsult);
                            System.out.println("💰 Solde disponible sur " + refConsult + " : " + solde + "€");
                        } catch (Exception e) {
                            System.out.println("❌ Le compte n'existe pas ou une erreur est survenue.");
                        }
                        break;
                        
                    case 5:
                        System.out.println("Merci de votre visite et à bientôt ! 👋");
                        quitter = true;
                        break;
                        
                    default:
                        System.out.println("❌ Choix inconnu, veuillez réessayer.");
                }
            }
            
            scanner.close();
            
        } catch (Exception e) {
            System.err.println("🔴 Erreur fatale de connexion au serveur ! Avez-vous démarré WildFly ?");
            e.printStackTrace();
        }
    }
}
