�ON                                                                                                                                Attend que l'utilisateur fasse son choix parmi le menu.

 CHOICE [/C[:]touches] [/N] [/S] [/T[:]c,nn] [texte]

 /C[:]touches Sp�cifie les touches configurables. Le d�faut est ON
/N           Ne pas afficher les touches et le ? � l'invite.
/S           Permet de distinguer majuscules et minuscules.
/T[:]c,nn    Touche par d�faut c apr�s nn secondes.
texte        Texte � afficher avant l'invite.

ERRORLEVEL est �tabli de mani�re � d�tecter une erreur de choix de touche.

 Commutateur sur la ligne de commande non valide. Forme attendue :
     CHOICE: syntaxe du commutateur touches non valide. Forme attendue: /C[:]touches
 CHOICE: syntaxe du d�lai d'attente incorrecte. Forme attendue : Tc,nn ou T:c,nn
 CHOICE: La valeur par d�faut du d�lai d'attente n'a pas �t� d�finie.
 CHOICE: seulement un caract�re autoris�. Forme attendue :
     CHOICE: requiert MS-DOS version 4.0 ou ult�rieure.
                                                                                                                                            ���0�!<���W���N�e���� �����!G�=&�� +ã����>����� �<u�8</tA< t�<	t��= u <"u�"��/��<t�:�t�F��</t�F�Ļ��������������<?t$<Ct7<Ntm<Ttq<Su�� �l���������������������<:uF�< t<	t<t
</t�F��� ���t�A����^���U� �.��<:uF�<tN</tJ< tF<	tB�F�<,u8F�<0r1<9w-���F�<0s���<9v�����
 ����âF������ ���� �����>t��� ���< t
��� �F���� ��t�X� ��� �� �>u)���[�!���!G�= t��,�!���]�!��?�!�> t-�,�!�6��!���� u�,�!86t�6�u����!��>t�E �= t�t
�����!�ݴ���!���!��
�!���ǴL�!PWR�3���� t�!G��Z_X�SW<ar<zw, �<�r�>���2�+�&�_[�