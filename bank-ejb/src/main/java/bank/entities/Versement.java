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
