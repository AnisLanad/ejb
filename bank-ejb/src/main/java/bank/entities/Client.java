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
