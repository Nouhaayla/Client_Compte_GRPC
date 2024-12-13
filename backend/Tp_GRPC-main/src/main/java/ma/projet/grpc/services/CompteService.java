package ma.projet.grpc.services;

import ma.projet.grpc.entities.Compte;
import ma.projet.grpc.repositories.ComptRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class CompteService {
    private final ComptRepository compteRepository;

    public CompteService(ComptRepository compteRepository) {
        this.compteRepository = compteRepository;
    }

    public List<Compte> findAllComptes() {
        return compteRepository.findAll();
    }

    public Compte findCompteById(String id) {
        return compteRepository.findById(id).orElse(null);
    }

    public Compte save(Compte compte) {
        return compteRepository.save(compte);
    }

    public List<Compte> findByType(String type) {
        return compteRepository.findByType(type);
    }

    // Nouvelle méthode pour supprimer un compte par ID
    public void delete(String id) {
        compteRepository.deleteById(id);
    }
}
