package bank.web;

import bank.entities.CompteCourant;
import bank.entities.CompteEpargne;
import bank.entities.Operation;
import bank.interfaces.BanqueLocal;

import jakarta.ejb.EJB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.Date;
import java.util.List;

@WebServlet("/banque")
public class BanqueServlet extends HttpServlet {

    @EJB
    private BanqueLocal banqueInterface;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Redirige par défaut vers la vue JSP
        request.getRequestDispatcher("/banque.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        String codeCompte = request.getParameter("codeCompte");
        
        try {
            if ("consulter".equals(action)) {
                // Actions de consultation (Solde et opérations) seront traitées ci-dessous de toute façon
                request.setAttribute("message", "Consultation du compte: " + codeCompte);
                
            } else if ("verser".equals(action)) {
                double montant = Double.parseDouble(request.getParameter("montant"));
                banqueInterface.verser(codeCompte, montant);
                request.setAttribute("message", "Versement de " + montant + " effectué avec succès.");
                
            } else if ("retirer".equals(action)) {
                double montant = Double.parseDouble(request.getParameter("montant"));
                banqueInterface.retirer(codeCompte, montant);
                request.setAttribute("message", "Retrait de " + montant + " effectué avec succès.");
                
            } else if ("ajouter".equals(action)) {
                // Implémentation de la création d'un compte
                String typeCompte = request.getParameter("typeCompte");
                Long codeClient = Long.parseLong(request.getParameter("codeClient"));
                
                if ("Courant".equals(typeCompte)) {
                    CompteCourant cc = new CompteCourant();
                    cc.setCodeCompte(codeCompte);
                    cc.setDateCreation(new Date());
                    cc.setSolde(Double.parseDouble(request.getParameter("soldeInitial")));
                    cc.setDecouvert(Double.parseDouble(request.getParameter("decouvert")));
                    banqueInterface.ajouterCompte(cc, codeClient);
                } else if ("Epargne".equals(typeCompte)) {
                    CompteEpargne ce = new CompteEpargne();
                    ce.setCodeCompte(codeCompte);
                    ce.setDateCreation(new Date());
                    ce.setSolde(Double.parseDouble(request.getParameter("soldeInitial")));
                    ce.setTaux(Double.parseDouble(request.getParameter("taux")));
                    banqueInterface.ajouterCompte(ce, codeClient);
                }
                request.setAttribute("message", "Le compte " + codeCompte + " a été créé avec succès.");
            }

            // Récupérer les informations nécessaires de la base de données après toute action
            if (codeCompte != null && !codeCompte.isEmpty()) {
                double solde = banqueInterface.consulterSolde(codeCompte);
                List<Operation> operations = banqueInterface.consulterOperations(codeCompte);
                
                // Mettre ces informations dans la page JSP via l'objet request
                request.setAttribute("codeCompte", codeCompte);
                request.setAttribute("solde", solde);
                request.setAttribute("operations", operations);
            }
        } catch (Exception e) {
            request.setAttribute("error", "Erreur: " + e.getMessage());
        }

        // Rendre la page JSP au Navigateur
        request.getRequestDispatcher("/banque.jsp").forward(request, response);
    }
}