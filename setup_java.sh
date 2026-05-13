#!/bin/bash
DIR_ENTITIES="~/Active/serveurs/bank-system/bank-ejb/src/main/java/bank/entities"
DIR_INTERFACES="~/Active/serveurs/bank-system/bank-ejb/src/main/java/bank/interfaces"
DIR_EJB="~/Active/serveurs/bank-system/bank-ejb/src/main/java/bank/ejb"

eval DIR_ENTITIES=$DIR_ENTITIES
eval DIR_INTERFACES=$DIR_INTERFACES
eval DIR_EJB=$DIR_EJB

cat << 'JAVA' > $DIR_ENTITIES/Client.java
package bank.entities;
import jakarta.persistence.*;
import java.io.Serializable;
import java.util.Collection;
@Entity
public class Client implements Serializable {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long idClient;
    private String nom;
    @OneToMany(mappedBy = "client", fetch = FetchType.LAZY)
    private Collection<Compte> comptes;
    public Client() {}
    public Client(String nom) { this.nom = nom; }
    public Long getIdClient() { return idClient; }
    public void setIdClient(Long idClient) { this.idClient = idClient; }
    public String getNom() { return nom; }
    public void setNom(String nom) { this.nom = nom; }
    public Collection<Compte> getComptes() { return comptes; }
    public void setComptes(Collection<Compte> comptes) { this.comptes = comptes; }
}
JAVA

cat << 'JAVA' > $DIR_ENTITIES/Compte.java
package bank.entities;
import jakarta.persistence.*;
import java.io.Serializable;
import java.util.Collection;
import java.util.Date;
@Entity
@Inheritance(strategy = InheritanceType.SINGLE_TABLE)
@DiscriminatorColumn(name = "TYPE_CPTE", discriminatorType = DiscriminatorType.STRING, length = 2)
public abstract class Compte implements Serializable {
    @Id
    private String codeCompte;
    private Date dateCreation;
    private double solde;
    @ManyToOne
    @JoinColumn(name = "CODE_CLI")
    private Client client;
    @OneToMany(mappedBy = "compte", fetch = FetchType.LAZY)
    private Collection<Operation> operations;
    public Compte() {}
    public Compte(String codeCompte, Date dateCreation, double solde) {
        this.codeCompte = codeCompte; this.dateCreation = dateCreation; this.solde = solde;
    }
    public String getCodeCompte() { return codeCompte; }
    public void setCodeCompte(String codeCompte) { this.codeCompte = codeCompte; }
    public Date getDateCreation() { return dateCreation; }
    public void setDateCreation(Date dateCreation) { this.dateCreation = dateCreation; }
    public double getSolde() { return solde; }
    public void setSolde(double solde) { this.solde = solde; }
    public Client getClient() { return client; }
    public void setClient(Client client) { this.client = client; }
    public Collection<Operation> getOperations() { return operations; }
    public void setOperations(Collection<Operation> operations) { this.operations = operations; }
}
JAVA

cat << 'JAVA' > $DIR_ENTITIES/CompteCourant.java
package bank.entities;
import jakarta.persistence.DiscriminatorValue;
import jakarta.persistence.Entity;
import java.util.Date;
@Entity
@DiscriminatorValue("CC")
public class CompteCourant extends Compte {
    private double decouvert;
    public CompteCourant() {}
    public CompteCourant(String codeCompte, Date dateCreation, double solde, double decouvert) {
        super(codeCompte, dateCreation, solde);
        this.decouvert = decouvert;
    }
    public double getDecouvert() { return decouvert; }
    public void setDecouvert(double decouvert) { this.decouvert = decouvert; }
}
JAVA

cat << 'JAVA' > $DIR_ENTITIES/CompteEpargne.java
package bank.entities;
import jakarta.persistence.DiscriminatorValue;
import jakarta.persistence.Entity;
import java.util.Date;
@Entity
@DiscriminatorValue("CE")
public class CompteEpargne extends Compte {
    private double taux;
    public CompteEpargne() {}
    public CompteEpargne(String codeCompte, Date dateCreation, double solde, double taux) {
        super(codeCompte, dateCreation, solde);
        this.taux = taux;
    }
    public double getTaux() { return taux; }
    public void setTaux(double taux) { this.taux = taux; }
}
JAVA

cat << 'JAVA' > $DIR_ENTITIES/Operation.java
package bank.entities;
import jakarta.persistence.*;
import java.io.Serializable;
import java.util.Date;
@Entity
@Inheritance(strategy = InheritanceType.SINGLE_TABLE)
@DiscriminatorColumn(name = "TYPE_OP", discriminatorType = DiscriminatorType.STRING, length = 1)
public abstract class Operation implements Serializable {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long numero;
    private Date dateOperation;
    private double montant;
    @ManyToOne
    @JoinColumn(name = "CODE_CPTE")
    private Compte compte;
    public Operation() {}
    public Operation(Date dateOperation, double montant, Compte compte) {
        this.dateOperation = dateOperation; this.montant = montant; this.compte = compte;
    }
    public Long getNumero() { return numero; }
    public void setNumero(Long numero) { this.numero = numero; }
    public Date getDateOperation() { return dateOperation; }
    public void setDateOperation(Date dateOperation) { this.dateOperation = dateOperation; }
    public double getMontant() { return montant; }
    public void setMontant(double montant) { this.montant = montant; }
    public Compte getCompte() { return compte; }
    public void setCompte(Compte compte) { this.compte = compte; }
}
JAVA

cat << 'JAVA' > $DIR_ENTITIES/Versement.java
package bank.entities;
import jakarta.persistence.DiscriminatorValue;
import jakarta.persistence.Entity;
import java.util.Date;
@Entity
@DiscriminatorValue("V")
public class Versement extends Operation {
    public Versement() {}
    public Versement(Date dateOperation, double montant, Compte compte) {
        super(dateOperation, montant, compte);
    }
}
JAVA

cat << 'JAVA' > $DIR_ENTITIES/Retrait.java
package bank.entities;
import jakarta.persistence.DiscriminatorValue;
import jakarta.persistence.Entity;
import java.util.Date;
@Entity
@DiscriminatorValue("R")
public class Retrait extends Operation {
    public Retrait() {}
    public Retrait(Date dateOperation, double montant, Compte compte) {
        super(dateOperation, montant, compte);
    }
}
JAVA

cat << 'JAVA' > $DIR_INTERFACES/BanqueLocal.java
package bank.interfaces;
import jakarta.ejb.Local;
import bank.entities.Compte;
import bank.entities.Operation;
import java.util.List;
@Local
public interface BanqueLocal {
    void ajouterCompte(Compte c, Long codeClient);
    double consulterSolde(String codeCompte);
    void verser(String codeCompte, double montant);
    void retirer(String codeCompte, double montant);
    List<Operation> consulterOperations(String codeCompte);
}
JAVA

cat << 'JAVA' > $DIR_INTERFACES/BanqueRemote.java
package bank.interfaces;
import jakarta.ejb.Remote;
import bank.entities.Compte;
import bank.entities.Operation;
import java.util.List;
@Remote
public interface BanqueRemote {
    void ajouterCompte(Compte c, Long codeClient);
    double consulterSolde(String codeCompte);
    void verser(String codeCompte, double montant);
    void retirer(String codeCompte, double montant);
    List<Operation> consulterOperations(String codeCompte);
}
JAVA

cat << 'JAVA' > $DIR_EJB/BanqueEJB.java
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
JAVA

cat << 'XML' > ~/Active/serveurs/bank-system/bank-ejb/src/main/resources/META-INF/persistence.xml
<?xml version="1.0" encoding="UTF-8"?>
<persistence version="3.0"
             xmlns="https://jakarta.ee/xml/ns/persistence"
             xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
             xsi:schemaLocation="https://jakarta.ee/xml/ns/persistence https://jakarta.ee/xml/ns/persistence/persistence_3_0.xsd">
    <persistence-unit name="BanquePU" transaction-type="JTA">
        <jta-data-source>java:jboss/datasources/ExampleDS</jta-data-source>
        <properties>
            <property name="hibernate.hbm2ddl.auto" value="update"/>
            <property name="hibernate.show_sql" value="true"/>
            <property name="hibernate.dialect" value="org.hibernate.dialect.H2Dialect"/>
        </properties>
    </persistence-unit>
</persistence>
XML

cat << 'JAVA' > ~/Active/serveurs/bank-system/bank-client/src/main/java/bank/client/ClientMain.java
package bank.client;
import bank.interfaces.BanqueRemote;
import bank.entities.CompteCourant;
import java.util.Date;
import java.util.Properties;
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
            BanqueRemote proxy = (BanqueRemote) ctx.lookup("ejb:/bank-ejb/BK!bank.interfaces.BanqueRemote");
            
            System.out.println("Création compte...");
            proxy.ajouterCompte(new CompteCourant("CC1", new Date(), 5000, 1000), 1L);
            
            System.out.println("Versement...");
            proxy.verser("CC1", 2000);
            
            System.out.println("Solde actuel : " + proxy.consulterSolde("CC1"));
            
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
JAVA

