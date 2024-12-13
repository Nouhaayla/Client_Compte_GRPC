package ma.projet.grpc.repositories;

import ma.projet.grpc.entities.Compte;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ComptRepository extends JpaRepository<Compte,String> {
    List<Compte> findByType(String type);
}
