package pe.upeu.auth.entity;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@NoArgsConstructor
@AllArgsConstructor
@Data
@Builder
public class TokenDto {
    private Integer id;
    private String token;
    private String userName; // Campo para el nombre de usuario
    private String role;     // Campo para el rol del usuario

}
