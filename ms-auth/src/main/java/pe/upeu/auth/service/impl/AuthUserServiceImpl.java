package pe.upeu.auth.service.impl;

import pe.upeu.auth.dto.AuthUserDto;

import pe.upeu.auth.entity.AuthUser;
import pe.upeu.auth.entity.AuthUser.UserRole;
import pe.upeu.auth.entity.TokenDto;
import pe.upeu.auth.repository.AuthRepository;
import pe.upeu.auth.security.JwtProvider;
import pe.upeu.auth.service.AuthUserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class AuthUserServiceImpl implements AuthUserService {
    @Autowired
    AuthRepository authRepository;
    @Autowired
    PasswordEncoder passwordEncoder;
    @Autowired
    JwtProvider jwtProvider;

    @Override
    public AuthUser save(AuthUserDto authUserDto) {
        Optional<AuthUser> user = authRepository.findByUserName(authUserDto.getUserName());
        if (user.isPresent())
            return null;
        String password = passwordEncoder.encode(authUserDto.getPassword());
        AuthUser authUser = AuthUser.builder()
                .userName(authUserDto.getUserName())
                .password(password) // Contraseña ya codificada 
                .email(authUserDto.getEmail())// Asumiendo que el DTO tiene un campo 'role' de tipo String
                .firstName(authUserDto.getFirstName())
                .lastName(authUserDto.getLastName())
                .phoneNumber(authUserDto.getPhoneNumber())
                .address(authUserDto.getAddress())
                .dateOfBirth(authUserDto.getDateOfBirth())
                .role(null == authUserDto.getRole() ? UserRole.USER : authUserDto.getRole()) // Asignar rol, por defecto USER si es null
                .profilePictureUrl(authUserDto.getProfilePictureUrl())
                .build();

        return authRepository.save(authUser);
    }

    @Override
    public TokenDto login(AuthUserDto authUserDto) {
        Optional<AuthUser> userOptional = authRepository.findByUserName(authUserDto.getUserName());

        if (!userOptional.isPresent()) {
            System.out.println("Login fallido: Usuario no encontrado para: " + authUserDto.getUserName());
            return null; // Usuario no encontrado
        }

        AuthUser user = userOptional.get();

        // Verifica si la contraseña proporcionada coincide con la almacenada (codificada)
        if (passwordEncoder.matches(authUserDto.getPassword(), user.getPassword())) {
            // Si las credenciales son válidas, crea un token JWT
            String generatedToken = jwtProvider.createToken(user);

            // *** CAMBIO AQUI ***
            // Ahora devuelve un TokenDto que contiene el token, el userName y el role.
            return TokenDto.builder()
                    .token(generatedToken)
                    .id(user.getId())
                    .userName(user.getUserName()) // Obtiene el userName del usuario autenticado
                    .role(user.getRole().name())   // Obtiene el rol y lo convierte a su nombre de String (ej. "ADMIN", "USER")
                    .build();
        } else {
            System.out.println("Login fallido: Contraseña incorrecta para usuario: " + authUserDto.getUserName());
            return null; // Contraseña incorrecta
        }
    }

    @Override
    public TokenDto validate(String token) {
        // 1. Validar el token JWT
        if (!jwtProvider.validate(token)) {
            return null; // Token inválido
        }

        // 2. Obtener el nombre de usuario del token
        String username = jwtProvider.getUserNameFromToken(token);

        // 3. Buscar el usuario en la base de datos
        Optional<AuthUser> authUserOptional = authRepository.findByUserName(username);

        if (!authUserOptional.isPresent()) {
            return null; // Usuario no encontrado en la base de datos
        }

        AuthUser authUser = authUserOptional.get();

        // 4. Obtener el ID y el rol del usuario autenticado
        // Asegúrate de que authUser.getId() devuelve un Integer o castéalo si es necesario
        Integer userId = authUser.getId(); // <-- Obtén el ID aquí. ASUME que authUser.getId() es Integer.
        // Si AuthUser.getId() devuelve Long, cámbialo a:
        // Integer userId = authUser.getId().intValue();
        // O cambia el tipo de 'id' en TokenDto a Long.
        // Lo ideal es que los tipos coincidan.

        String userRole = authUser.getRole().name();

        // 5. Construir y devolver el TokenDto con la información requerida usando el builder
        return TokenDto.builder()
                .token(token)
                .id(userId)       // <-- ¡Pasa el ID aquí!
                .userName(username)
                .role(userRole)
                .build();
    }

    @Override
    public List<AuthUser> lista(){
        return authRepository.findAll();
    }

    @Override
    public Optional<AuthUser> buscarPorId(Integer id) {
        return authRepository.findById(id);
    }
}
