package bank.ejb;
import bank.entities.*;
import bank.interfaces.BanqueLocal;
import bank.interfaces.BanqueRemote;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.Query;
import java.util.Date;
import java.util.List;

@Stateless(name="BK")
public class BanqueEJB implements BanqueLocal, BanqueRemote {
    @PersistenceContext(unitName = "BanquePU")
    private EntityManager em;

    @Override
    public void ajouterCompte(Compte c, Long idClient) {
        Client client = em.find(Client.class, idClient);
        if (client == null) {
            client = new Client("Client " + idClient);
            em.persist(client);
        }
        c.setClient(client);
        em.persist(c);
    }

    @Override
    public double consulterSolde(String codeCompte) {
        Compte cpte = em.find(Compte.class, codeCompte);
        if(cpte == null) throw new RuntimeException("Compte introuvable");
        return cpte.getSolde();
    }

    @Override
    public void verser(String codeCompte, double montant) {
        Compte cpte = em.find(Compte.class, codeCompte);
        cpte.setSolde(cpte.getSolde() + montant);
        Versement v = new Versement(new Date(), montant, cpte);
        em.persist(v);
    }

    @Override
    public void retirer(String codeCompte, double montant) {
        Compte cpte = em.find(Compte.class, codeCompte);
        if(cpte.getSolde() < montant) throw new RuntimeException("Solde insuffisant");
        cpte.setSolde(cpte.getSolde() - montant);
        Retrait r = new Retrait(new Date(), montant, cpte);
        em.persist(r);
    }

    @Override
    public List<Operation> consulterOperations(String codeCompte) {
        Query req = em.createQuery("select o from Operation o where o.compte.codeCompte=:code");
        req.setParameter("code", codeCompte);
        return req.getResultList();
    }
}
