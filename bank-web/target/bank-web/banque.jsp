<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="bank.entities.Operation" %>
<%@ page import="bank.entities.Versement" %>
<!DOCTYPE html>
<html>
<head>
    <title>Gestion des Comptes Bancaires</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .section { margin-bottom: 30px; padding: 15px; border: 1px solid #ccc; border-radius: 5px; }
        table { border-collapse: collapse; width: 100%; max-width: 600px; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
        .message { color: green; font-weight: bold; }
        .error { color: red; font-weight: bold; }
        .field-group { margin-bottom: 10px; }
    </style>
</head>
<body>

    <h1>Gestion des Comptes Bancaires</h1>

    <% if (request.getAttribute("message") != null) { %>
        <p class="message"><%= request.getAttribute("message") %></p>
    <% } %>
    <% if (request.getAttribute("error") != null) { %>
        <p class="error"><%= request.getAttribute("error") %></p>
    <% } %>

    <div class="section">
        <h3>Consulter ou Effectuer une Opération</h3>
        <form action="${pageContext.request.contextPath}/banque" method="post">
            <div class="field-group">
                <label>Code Compte :</label>
                <input type="text" name="codeCompte" required value="<%= request.getAttribute("codeCompte") != null ? request.getAttribute("codeCompte") : "" %>" />
            </div>
            
            <div class="field-group">
                <label>Montant (si transaction) :</label>
                <input type="number" step="0.01" name="montant" />
            </div>

            <button type="submit" name="action" value="consulter">Consulter</button>
            <button type="submit" name="action" value="verser">Verser</button>
            <button type="submit" name="action" value="retirer">Retirer</button>
        </form>
    </div>

    <% 
        String codeCompte = (String) request.getAttribute("codeCompte");
        if (codeCompte != null && !codeCompte.isEmpty()) { 
    %>
    <div class="section">
        <h3>Informations du Compte</h3>
        <p><strong>Numéro du Compte :</strong> <%= codeCompte %></p>
        <p><strong>Solde :</strong> <%= request.getAttribute("solde") %> MAD</p>

        <h4>Historique des Opérations</h4>
        <% 
            List<Operation> operations = (List<Operation>) request.getAttribute("operations");
            if (operations != null && !operations.isEmpty()) {
        %>
            <table>
                <tr>
                    <th>Numéro Opération</th>
                    <th>Date</th>
                    <th>Type</th>
                    <th>Montant</th>
                </tr>
                <% for (Operation op : operations) { %>
                    <tr>
                        <td><%= op.getNumero() %></td>
                        <td><%= op.getDateOperation().toString() %></td>
                        <td><%= (op instanceof Versement) ? "Versement" : "Retrait" %></td>
                        <td><%= op.getMontant() %></td>
                    </tr>
                <% } %>
            </table>
        <% } else { %>
            <p>Aucune opération trouvée.</p>
        <% } %>
    </div>
    <% } %>

    <div class="section">
        <h3>Ajouter un Nouveau Compte</h3>
        <form action="${pageContext.request.contextPath}/banque" method="post">
            <input type="hidden" name="action" value="ajouter" />
            
            <div class="field-group">
                <label>Code Client (Id) :</label>
                <input type="number" name="codeClient" required />
            </div>
            <div class="field-group">
                <label>Nouveau Code Compte :</label>
                <input type="text" name="codeCompte" required />
            </div>
            <div class="field-group">
                <label>Type de Compte :</label>
                <select name="typeCompte">
                    <option value="Courant">Courant</option>
                    <option value="Epargne">Epargne</option>
                </select>
            </div>
            <div class="field-group">
                <label>Solde Initial :</label>
                <input type="number" step="0.01" name="soldeInitial" value="0.0" />
            </div>
            <div class="field-group">
                <label>Découvert (si Courant) :</label>
                <input type="number" step="0.01" name="decouvert" value="0.0" />
            </div>
            <div class="field-group">
                <label>Taux (si Epargne) :</label>
                <input type="number" step="0.01" name="taux" value="0.0" />
            </div>
            
            <button type="submit">Ajouter Compte</button>
        </form>
    </div>

</body>
</html>