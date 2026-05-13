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
