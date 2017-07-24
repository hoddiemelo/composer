ME=`basename "$0"`
if [ "${ME}" = "install-hlfv1-unstable.sh" ]; then
  echo "Please re-run as >   cat install-hlfv1-unstable.sh | bash"
  exit 1
fi
(cat > composer.sh; chmod +x composer.sh; exec bash composer.sh)
#!/bin/bash
set -e

# Docker stop function
function stop()
{
P1=$(docker ps -q)
if [ "${P1}" != "" ]; then
  echo "Killing all running containers"  &2> /dev/null
  docker kill ${P1}
fi

P2=$(docker ps -aq)
if [ "${P2}" != "" ]; then
  echo "Removing all containers"  &2> /dev/null
  docker rm ${P2} -f
fi
}

if [ "$1" == "stop" ]; then
 echo "Stopping all Docker containers" >&2
 stop
 exit 0
fi

# Get the current directory.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the full path to this script.
SOURCE="${DIR}/composer.sh"

# Create a work directory for extracting files into.
WORKDIR="$(pwd)/composer-data-unstable"
rm -rf "${WORKDIR}" && mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# Find the PAYLOAD: marker in this script.
PAYLOAD_LINE=$(grep -a -n '^PAYLOAD:$' "${SOURCE}" | cut -d ':' -f 1)
echo PAYLOAD_LINE=${PAYLOAD_LINE}

# Find and extract the payload in this script.
PAYLOAD_START=$((PAYLOAD_LINE + 1))
echo PAYLOAD_START=${PAYLOAD_START}
tail -n +${PAYLOAD_START} "${SOURCE}" | tar -xzf -

# stop all the docker containers
stop



# run the fabric-dev-scripts to get a running fabric
./fabric-dev-servers/downloadFabric.sh
./fabric-dev-servers/startFabric.sh
./fabric-dev-servers/createComposerProfile.sh

# pull and tage the correct image for the installer
docker pull hyperledger/composer-playground:unstable
docker tag hyperledger/composer-playground:unstable hyperledger/composer-playground:latest


# Start all composer
docker-compose -p composer -f docker-compose-playground.yml up -d
# copy over pre-imported admin credentials
cd fabric-dev-servers/fabric-scripts/hlfv1/composer/creds
docker exec composer mkdir /home/composer/.composer-credentials
tar -cv * | docker exec -i composer tar x -C /home/composer/.composer-credentials

# Wait for playground to start
sleep 5

# Kill and remove any running Docker containers.
##docker-compose -p composer kill
##docker-compose -p composer down --remove-orphans

# Kill any other Docker containers.
##docker ps -aq | xargs docker rm -f

# Open the playground in a web browser.
case "$(uname)" in
"Darwin") open http://localhost:8080
          ;;
"Linux")  if [ -n "$BROWSER" ] ; then
	       	        $BROWSER http://localhost:8080
	        elif    which xdg-open > /dev/null ; then
	                xdg-open http://localhost:8080
          elif  	which gnome-open > /dev/null ; then
	                gnome-open http://localhost:8080
          #elif other types blah blah
	        else
    	            echo "Could not detect web browser to use - please launch Composer Playground URL using your chosen browser ie: <browser executable name> http://localhost:8080 or set your BROWSER variable to the browser launcher in your PATH"
	        fi
          ;;
*)        echo "Playground not launched - this OS is currently not supported "
          ;;
esac

echo
echo "--------------------------------------------------------------------------------------"
echo "Hyperledger Fabric and Hyperledger Composer installed, and Composer Playground launched"
echo "Please use 'composer.sh' to re-start, and 'composer.sh stop' to shutdown all the Fabric and Composer docker images"

# Exit; this is required as the payload immediately follows.
exit 0
PAYLOAD:
� �hvY �=�r۸����sfy*{N���aj0Lj�LFI��匧��(Y�.�n����P$ѢH/�����W��>������V� %S[�/Jf����4���h4@�P��
)F�4l25yضWo��=��� � ���h�c�1p�?a�lT�c�x�}°�(�=��+��#[ <q,���7�-���BZ�j�`�ۦ(Z}U��.E�󄵋~�鎬��:����L�'�QZghBK��6�"�� KTӰ۫���av�]��m���jz��)U*�*R�,U*fr�]����/ �&lɮ�]���:uh-U��.�;ZKnX�B�,�L��7X'���Ayx$n�ݧ�V,��M`���R��03[�A�~�}v6��uY�8�E�"��#	��^�`��*k��6�4\Ue��\�jB1�~7�fF��p-ӶLe7�ˇ��35�iڍ3C���J�0C�ґ�D��G]%���l3�Ƙ%��*���<g.���8���W䰁j�����/�s�Lw�j��4��Յ�S+����`��;�<��Gl�l�%挺)�jR����"��fO%bT,Uk)=;����0��dQ׿t��K���D<�/h�6�D����ǥ>��x#j�~+Ċ�o/��p���a���G�?�
�'@xpJ����ϙ�V����;�m�̿p����矍�x!.ph��<����Ͼ�4T=Ґ�e��@@?�&��T-����I��V)��)���/i����4ѯșf�h�G��ֆ_̑,�x:?��s����6��e��7e�����s������o���H;���
�ư���n��� �h�����@�X��$�(L�	^�oj&�@����1 Y��y0���&q~��a�mWj���>���`��d���ڗL�c��$ɮ�1�)�����
�m�#1s�8/��h�׼�m�I�P�JGF�Fo3IW��]�����Q�h۪�c���^��w�t�U�fH����'�t��L
�?���Ep�0z\��l;�����h8m�Ij�}�zYl�{��,4�~Nb*gT�o�u�Q�_*ܲ�5-M���\`�q���8�1(�Ck����뀠�G=��-W'Nq�tdtUM#�ڂ=�Q"���޾�(`S�B�c�/^R)��{��IX�6���R[��&YdA~�h|x��ԑ"�J� �j�-�fgۡ���D�FtWӰ��k��Ij�Z*j��l\����zwr��2�Z=@*�n�
�bf<�Fp��W�6@T�x�<2f��D��?L��b½r��b�{d�2�;��|����B7p�Dfު�y$��F_�~�,��)2tmH$0�>:7}3���Ź�+l�z�WE���C
aڛ�9t:h�<�ݣ5(��P��U� �X6�g@S�O{�aN�= �i�!��cN��藔_�P���ͯ��/h���}Q�M>'8cg�t/�8��aA����5�T�cDoh^� �!<x�:~:�e�j:ܬ�_*�Y�1#=�����d�����|�0G�����X �,�ŧ��������v�x֙�� �d�iӦ6�,C�)l�f-��i�e���@֏a�t��wuBU�s��J��;����&�c���]��l?�@���$c9t��܌�,�Rgu�\ɕ��.���f��@ �\݆Ώ�H��n���A�8r	L��t(����:Q�x+��|2�w*��V�b�zV��R�z3�h�hg�h���˙.L��c��.����_�1�ćW�IT"�;��x>�὿��>���7��������Т���s��Y
X\�ɂ�N��?����]�_��κ=����"��Y����8����q�YV��8���끍��e����l9�\$�Q�����Bt#�뀇���]��g����&D�@(dZ��^��:�*���so�#�S����X=�3�ĹM��:`����݃����	�f������Â�\���pQA���S�%�7t��l@�2��i�����d�i�)�������@��J�uȗ=R��WI��9��v`�!DWs�<#��g,D&3��F�1js�2� L�	2EFM�6ЍP4(�(k�%S/T���0�}�����\�W�Sh��!��<�5F�U�� �_,���r�'n���//�w^(�̬�G7�k��U��#ǈ�C׏6pdOb5� �	p��h/�`�g��K���Q�C�;��b�l���M-]�vL�ڻo����^���S���7�_�G��GP�K5�э+`X^�˒�.H�^s�6��3�0����F��Ϟ��$`:�9o�C���%,/�w�,�(�#:c�,�������{���sE�y�����T��l2W$�Rd���J���_��Cs�r'p���N��������K84C���a;��F�!����[=���-����2�?�
�խw���P�1<�U��z'Ƣ��p����.f�(���(4�� ���2��ud4 ���n�9�#d�[���/(^�a�ϴ��l�?��	���8���u������/��s����x��^!��5QW�ޥax��&
̹�-H��T��멳�x&������K�=|� �o2���5�<�r��v �%�2���.�%r{�!�*���CI*���tY�T�Z����R�J����'��R�X�su�i�H_�"���r�џ`�|)���gy�.���R���i8��C#2�|x�;���b��3�'e.vu5�|e�����sՓ�I��\��Qo���l�KSX�e��W���J��5U���zw<��6f@�B
ض5M ��U�n4�w.�r����3o�v�%~j�}@X��wװ���>6�������Z�����������N׼�.\��%��9��� l��fv�n5S�6Y���6�K�i|���b�o�X,z�b���|�w�y������Z2�����{翉�o�?����\
���ð���G���������]�?HC~x�����Ea��ȷ������WRϖt��������U5
6b'n	@���SW`����-p�Ss�>,���s)�B��������<������|����`/�(���7`-*�ȫ�+P�T¿(}�VW�4�e�4����}.�X$���_N����~���$�T��v��1�pty��6�Ηa�����P����fr��ǹ������?���Fx��d��a�a�y��Az�&~C�u)J1�h����ЃG1x;ȕ�|�^�0~xf�[0�S�q�?���⿺2���t��|d��*W���GT����l��(�q�9o�L�R�	v�.�����a��3>$Ï�x�p��	�������H�ݡ����l�6��u�����<�v.��(�[��?A�n�YP��5uF}���o�������?��Z~�F���\b���
�'�V��+;�D��Hp<�!�B>�'�(��|BH$�F|G�;���_Q��5]�Vz�ߨ?�����~A���ӭ?Q����'�>����ۆ�no�_����-b�����W[���t��j�"�[���0{�/[���?lQ���k���cKu�o�y�)���q�+C|�D �O���a9"?�,���?�pWjcu�e6�=p��?ǷL�?7;�������G�x`�G��P�(m�Ӡ-�<���L~���?�����r���5,Y��?��Tz�#m�m�ˑ��3D(,��r���X��(�(���I���7v��Ea�b;M�Q[(2��6.�	�G��Pǵ}��Tm��;!I)�+��T��2��X�H�{��˥�穔���� �۹�XtKz��j،$�C�m\5��v4H�Or�i���@�����ٚ��R�z�B���v�������N#���7�|,]d�Ś��T�u��&��u��qO8��۹�Vŷ�Q�����䞾�to��iE8op��~Z�=�BU⊝�z�7s��Q���2(��B5ǔ�9����4f��^?>O6
G� ut��e���z�R����ޥ���#.c�ǧ}�'�'U鸐<�z~Q(��k\��I�Óc�\~[<o\J�B�!�`p|t\v�cADc�*��G�^h�^�ߨ&O�H&����l��'Ķ�M���i_drb2��\$��l��R-ԍ|?^|���N,���\}������z\+�Z'�x���U
����9H�+�]h�c��4̶��j2_y4��fz %#�#<����X�c�_.$�֎$��b!e�^5s��n!u �=�Tv��\2�^��������C��K%�Ieb�{#�#.w�1����ȴłTK�R�}p{�������	�w�˄p��t��W�tN���6�'��f��kW����+�6��!���q��^[/�ʌ:L�x�Y��Ž�:ay���#���U8���7�v^�+�5���Z?��a���ƶ ò1&����	��0�����F���}uw�������5����t��O�e���ϵ@�N:,��hq �	I}Jr�}�&�����,3��ut�f�� �Oj$�v���iI�3�-,f�5��e�P�,��A&WJ�V?eՊe�P�^f�T��e��4�U��R|�[����ѠP��sY����5�p�%r�"F�5w�O�W؃�B�(��R�o�c�z�?�<�~v�6��:����n�Sw}O>��������k���_K�s������ɾ��H�GcWHZ<R�GmQ��Kʤkr5�pq�v#6ߴM��}J��i�Е��Oߺ�L9�1Ѩ���A�{��NOl�VLb���՜��{{�|��O=j����M���%-��K\�@�cq~����o���@�0����%�_����2N�A�h��g8�0�6���Wy�ܖ
�]0zh9� <�z8@��%/�d�m�@�T]%SFGuɺzI�6�ɺ�����QK�̷��$�����r\���#�E�w- �6z���@|I�q�tń
��
� v��P3$	�:$j)�)B`߰���;�ȣ�.���k��G�<���Ge^R�5�N�>6�>Z�5��8Z�C^��$u��A�n.��:HD�,�#q8+����-ԮE�*�����q���I6
C'$�߾�0�B3�&�e��n{�OJ��m�����xl�jw�����n�m�����`���$��\�8 !�]�ZA�p����p���x3o�(������_����_U��9>5p�F;m0�g��$RT����|�h���僛�v�	&�@�DX/k�)&��A�J[��MU	�Z�ABW�ˮ�}��q$����O58�xB�}���n"��4��t��E�~���23F��x\�&�Op]��r�Yn�Ѕƾ�L4o�3\��C�ʰ}̂tO����m���Į��}��^�??�������ޕLܻ�%���e;�6�71��2��>k���NP��2?''�9Fm�苃{�k���=Ài���}A���K0�NS�=i�)D�RCB�sM�(|t�L�jl�"$H��J�\���?��i�����j�����j�������D�D0j�\�.C<����D7�����my��A�'kLG�S�vmc
��b�����M������q�'�;�с���������'.;����OQ��R�i�&Ӯ��G�����'k*X6�f��oIt�!�T|8��H Шt��	��
�X�
)V���t�&sT:PՉ�"�N�]��5\6�萩���\[����w]�L���F��f�H����Fb?$~�Je�u��˜�?�_y�MϟC
w�ܟ:5M|��}�we ��P�[I���g&y
�1�e�a�h�a��=�7w����D���*#��I��D����T<Il���Q���^ɇ��%����[�����?>���	�o����?��M��ɿ�C����� ~u���_�}k�/0V�m�#�I�ɟ}��9*)�^\V�d$�K�X������^L��r����۾񌜄JO��i��}������_��,���G?3v������w>���V��~$���?@��B֚��� ����nC?{���+��������WB�� �OV��-�F�c��`Lz��[�*�t��o��LAI�gM�a�#FU����J�Vc�3f� V�mV�� �:�u2���v`��a����vBZ�ّyyIG���\8�%���i'��BA�g�t���EZ?��`sN�x����|�f�P������gS"lB\���}iXw��P�9qs��;/���eK���XBݶ�*�a	n^>k7�	o�VMjЮ�6=����`�r�.�M���l�=6���U��Mv���bѹJ�֪��_�r�Y�:�gJ��LB�D�{B.b����H����^�:�AcE(�n�	&�~�6kcb�!n�4B�-�1F������<���ɩ���ME���N1a��xrV�O�E�=�����&L��C�u�W���YXo�YLp�`�LZO,��R39�W��)w���4U�|�D�6I0k5�V�Ώ��l,%���L���"rD�'���Fx�<A]�~�Zm����+���+���+���+���+�+�++쒸+꒸+�؆��B1�w�7:z�M$�?�VQ,r;����f'"U�0gK*Y.w"z=;Z\t;�����s�%��K����%
���]�|��\O�.��{�y'"n�~����{�jr:����46g���U�YZ���ݳ�>��F�U�dI��Q�Hk�DDk��x�	❺�˙�Ʉ�c� �D-y��!<��"�'�1��~���#��4��lyR��z�P��Ҧ�)�Oڱ~�ܾ�����,��PĔ�e�
5�'Ԅ]1�&k�F햚���ULS�A��OJ)z���� �p��ѱ�lv��I�Jȑz�^/;���C�
-�u�f�EV�������C�B;���o켶�6�����n���{�n���8��0�l�ˢy>�V]�.B�����Fh���(�҅�W6a��e����)ځuy3�F�5��e���-N
�ƣ�O�I�s������ �;B?x�?G�v�)+-�)�����VzVM��2�E�K�O�r�{���e��K7<���n�}��9����Ryl���D�t���"n5-ᘮ�ͩ�鲭M|"0M�W��F(
QZ"-2j�u<�r���Y�iV�Pc�T���&���>;�*���IV�ّ�R��0�K�¾6�T;�Q����CI��m�;q�L�Z˓a��j��xlPi�8�ce���c�ڞE�awڌ���w����x�idLa!�ǂ̪5��2@�C��êF7{����~*e��q-�|��s�ߢ��`Ik�R-h��h��N�Šz��(��������⃓
� �HB
���iw	���T������p�)����wf�R�?+��]^��ɂO�W�{�v��dQ�,��r�]�|sX���.ULuگ//���K��M��=�_��sK����a���G��*&~\L`ۋ��(��EY7`櫓~�}|ƕ<u'n�8�?��n�`��H-}Z��̅�)�[�ɖ��rUk��Z�F�yS���;lm4j(�Rx��jͱ�Z�l�`�%����a'C���y��ң��=�;e:�h���gnq�
-ж(sN��h�>r����lޠ��p.$�V��j�0��zo��j�Ϗ��N�D�i���j6_.��dX��}Z ӣ�I���;�J���My��Y�`b=�������Fe�x:_��ق�s)��-l�kd�Ԡ�"Q1[K����b⿺V'�"r$��#ʳam<:�RS��0%�b�Ė�W�H;O��d���G�������3!n��9b_�L ��yΤ��yϡ�9���Q�j���Qv�o&�F�#��#�5�2.���I�Z���Sk�j�[�c
�t��.��U��I��4�����LOg�^�'ȣ�֡�G��PR�R[<��3����
U7GvM-�Zb�L�λ���P7,��P�h��5��Ƌ��4�R	��EwD��$3�ҳ!ף	�2�p��h�0`�Ƽ���dLrnՖ�f��B�t��L����*e����*�}�ƀ������;��-�ɋ~o�)��7�����0���E��л�7�7��G����7V�+�5ќg���W�_@��Ȝ��b����E�i���?��hhK%�0�����_~I}�嗤߆���m����h㠈 �'�7��i>#�c�+�c�k�s`�e�|9}B�_ f_�����?D�=�L��O�_ļY`7C��N�hv�~���y�}�shY�(����Dh��Ѕ?ߦ�C�.���4�ܠ'|���9�}�������Ț���?׼��$c��G�_��{����"W��K���I�I��S��z=�;��t�N�31CRH�/�}H����$�E�ɘ0�1���b�Ce�!�Ѯ*�g�ؗ�.���C�p�MX�\�w^���Ms�W	������OXUa�T�����$��g���i�5�z��/[/���D�T��t���Jn)�' �E4�����}�	:\��?�� ��@H���@'݃Q��A"L���D���P�g�����AE�c�o���� >��F$ɩ�]Fkbw�	I�i���.�#�,�(�r�iX��#/ijy6 ������j[e�&$��������t�O�����pe;��7؆ ?���O�{�bP�Lэ1."����Q��x�.tS护���ը�Y�$
��?Ym�a[�ir���6�=~��Y;>3��!��i(l�5_�p ��q�B0zE��R�)�)>z�=IneP`X�h��6�!Y7 G�Ibթ*���;�}�uG�w�5�+�R�D��\��͛7�;&u��m;ذ���:o�æ�#~��DP�W����a���g~������ȵ��| D��M��iԵ��E��xy!���.��Ā7/1�X|��C�[k��!nE��y��T��Dgߟ��"_)��]�k\�9ވ�o ��fW�I�L�d3&�ٺ���u�dM#[W��x'R����]G�&�h���qzDHti)�v_`�����Mw6c��x-:�aL�� �����E8% �l����Y�W]��A�k%N}��<�сɨ�6��PRz���F.�ʋ�\ɨ�����8kdM�� _a��R��<p��ck�I�����\N��
�l��d����c��.7�	�FKP�S��Q��Bvd�_,WBT�{�v��A�l�2р�%�������ĹE��݂3iR`�����ml٨�����G�^2�&�Xo:Nǌ{�8���1T�4~kL֪�d[��o�J 	*J�9Bzr(���`�u���Ӑ�� p�����GٛF��"<4�W������xem�i*�B��P��H&����ynh�U�@��j!K�MٝPZ�
��b��D[ܘa�X�1�vc=R~��q��ثq �8_�;��O��﫳�m�a�����^��x'εe\��?���V��ţ�����}%��X!>�~Jhh]'*�r�c+�Ek�7�+Qf<���9�����,}���xV�nx+?wPn�����\}+ӐŖ�_��:��������N�=+�tĵ_��ʠK$�( R"��* Sb�^2��v�%�z Q)��De�'�2I��M�Ss�X2������+�=+8ͽ���}�i��t�>N�K>�)���Ґ�bK��sx�ŋ��2@J&�$I�x:���LE�x72 �d2�QR�t2�Ā$�;$@J2�Q�)�I�@��O%��C�wl�O�O�4f0p*q�_x���Û�����Sg�ܶQ	�M���Bx��n�}�R���Y��u�+su�tZ��K�1Wz&+�T���o�\�f�:�h<���*r)5���7N,T�gx�������_�e�Fe�Ш����u�讫U�co��� ���9٩��g���
�ZY��nXլ�T�bg�k�wD�MG�Fg�ed;c��8�ĵF��w�EQ�-	�b����o_"�>�XN�|�_������94��|9Z���H�ϳ�/g+��Q
�c��u�c�+��
_�MG��0������'ӑ^���s��Oᐼr)H��%�īK�uc+�#��Pi��J9��O˜تԏغg�������;Κ�E"��p��b�Ҡ
�ڲ���ü�9�/K�4C7�gYt*�\A��4���+kN[k�������í��>M� 	��^NiB̓~�lg0$v�xk'��pʇ���W��^��4��;=���z��I"�[��/�-_v��+��x��m����4��3L}�H��c׹c?z���D���=���{�5=[�������?�jer�W�t��Q���Q��׳��ٶ/�xK\���_?���|swZ�%�܀_��;|�)�����3�ϻ���"�������_>����us`.A�+�Ф@�������/(����}@�|�+���O�&X���C�oY��iX�����n��I��F����y�o
@ ����i�$���i�|������T���O������'�G3����H �3`?�3��~��G�������������_I�9
ŤH�1����Rd�.�#?��
c^$�2��+��K���Gݝ�8��O��?������c2y�g>*&�l�\���!J��hS��^FIy�b��4nz{���W�fyÏ:z�.��^��t3�{��9�}ѝL����P㟆�p�6�N}8�&��v<��=������,��<�~<���ڝ?8����/���!EO�}�X����I��(�����?�������E�O������&��	�?
���2��/���?���O	����H��_;q/�@�%B�������o���G����#�_�ET����O��o���$�9�0��t��%�����S�	�H���}����[�a���M��?"`���Z p��9���� �G�����ǋ/��Z=h�E�-e�T��t���m�穐���TVO���K�'����k�Y3���yi�$�����Շ���������I�l�⇊&�fi�85�Ge57�r�������p�6�Sf�W[��y�ɕV��wj�Y@�O���w�M����?���/�}>�}���Y���FH��Fg��+o�͂��\>^���6�cs������þO������4S����q��9w*M�.�-%kVM�P��]���<t9���7��ե(���m�ٶa��N�#S�N�oK`�����0`�����(�n�����a����%
5�����?Q0�	��	����	�������?�
`���I��E��ϭ�����{�{���Q +���&�?8��P�_^������k��=��}>��O7�|���U�/>�������!��s��;���z���v�殅�>��������dd���0�����%�L�7���/�F)g��b$9��$M\nj}~Ķ��6X��S]vx�2�������l��5��zTS���CH?UT;7V�w����9�k���/���Xn��v��#����>��e����p<3��V��*W�J:�Dnu��R�U��x^1Փz%#'idH���U��-������ �G���?�@���c���1�� ��ϭ�p��ٽp����$����Q@	ሣ��䩈��9��� &c6!�0dx�煐f��dB>��	Ș������?��h�;���S�kLe�.W�O��T�oO�a�����kӊ9�$AU}���E1r�{�3��x��<Io�Gu���u����v68��}�\�KFҭ�%i�O4�m���1^E���pI5�-;Ïj���Z����gq(x���p�[(p��!�+X�?�����s�9��E_�O����;㿝e��]C/��DHb�uF���xw����r�yӐs�t�{���&÷��������)_��V��3����$TՃǒ���$)c�W��sJ�y��F�R��/r>O�v��e������A��Z��Ӑ�-����O���� 꿠��8@��A��A��_��ЀE �'7��,	A�!�K��;��_���o'lVUe?�-B�Q�D?o���i!��'9z���,;)qV[���  �/�c 񭞽;�,U�joN�J��xq�l�G+��6�r�����i��g��ێ�v�RV��hV�S��:U�ҥ����Bc �QI଺h[��K�Y��۩de��4�H<����'�_���w���e��V��T���VI�r��<}����˵r��c���)Z R�l[��ӂHQ�-�i��6RSM:l{l*%��T�����/5������B��m��{��ݭ+e1��O�R5e2�4��$V�h���t�j�eK��Y��G���y�X�5��m̾�'Ţ���[olF2ލ8�?����X�(����C��@��/������C�
���4y����� 	����@������	$��( ��������_�������$?�9?�I!�#��ِ�%��y��b�y1f� �L����D)f���y?�������_N��$����^+��N��冋�ץ	nн��4+g�֦Ǟx�dW6?��:-��}t�;5WK�ꑻMMܗ��\0Jk=Y��A�����Z�=��]v�x����j���R��U%֫t�-�YT�����a���;� ��������%�G@��o���4�������?��!����<�q�?���O�7�?��C��/_~�/cT����� �?x���r��_뿭]kٳJǨ�T���0Y鳹}S��
���d���[��1����k�{j�/G��Ok��o�;�����'ՊG�X�]݉��bS���隽Us/X�ɰџr���~�[Wj����w4�r��G�d�'x�\-G0R3jwx�Տ�$oL�]�i�l����j^�%�+ʹ����w�b(��4gyc�Y/�84�VkK�ޜ�u�����*;�M�U[eӆ���l��0fE�$q}�<^z%A3��Y�ݼ'�ը���5��ª�Ue��}��MI�9Ġg��>99��$�#���X�e#���`�oA@��`�;����s�?������Z��?����;��<�H ��P���P�����>N�e�R X��ϭ�p�8�/����#dp���_����������=����M��C����w���=��b���3�#�O��m�� �� *��_��B� ��/��a�wQ(����` ����ԝ���H���9D� ��/���;�_��	��0�@T�����? �?���?��%������B�"`���3�@@�������� �#F�m! ������H ��� ��� ����
�`Q  ����������9j`���`��	�����������?�D�_:I���(@������po|��0�	��(�G���/P���P��G��������(�(������4[mc� ���[����̳{�?�N�OQg1���#2D�G��B6C�����8^�|2<�D�S��K%���,'��~����gx
����M����s�?}��Wk�S�Y�T�ܿ�l;!I#o6��jR�&��'���#j[��|��W�8<u��ލ;���rg�WS۵:kӝ�*�*�N=v��W� N�7s�v�;r�y̹�]�$긿tW�]�EǴ�e���Z�KƋX1�+S���|��/8f�a����P�����ԷP��C�W����)�����s���8�?���w��1�C)ku�Ji�XY�9��ڴ�:��߬P�Cv��������,sv��:��V�Ko�c#��w�=�I�ڭ}#�ԡbl��p��N�4�Uy�ޘZ����r��L��i��=�9�����f�;���?��	����C������/����/����+6��`������?迏�K��u���~�J}�cԾ����N�{QI��_��*�����"�4�S�*�f�u ��?f�t��u7,���L��S����Q,i��?1jiv�ƞ�6�>OvR��;Ic�O��)�6#&��㤙�k��vZ]�J��*'n�]?y�����ҩ��ۭ(�����������I��,Т}�VN�vlU�=ED�m�rZ$�(֠�8��b�Fz�,ʦn�FM8�F��񑦂� `&bdd~y�#���9��T�6g^C�(Fg1�Rj�+����<+E�L��um���݆��G�5'l���������6��Ϸ�����_�(���?)�p�����|�r����)X4�!���;�������_ݠ�[�X�_���H����i��=�e��Q �?�z��~@��?��������C�^��Y]U���W���/��r0v&%)�h�3��	\h������Γ��J??,]�Շ��v�UOg�s�s?�j~M�o����#����\O�|��y��7��)uٹ�./�ˋk	�mI�+w�$|̴�׬��(���Ω/��u]J���։6ט���ի�l���<���޳#��S�����,9C��)Y�����z�*3?����O���AWn=ъ�T�5����s��e͕d�_~�5����#�o�_�keS�����EU�9�n��bo��܏�N�����/�l�4��C�m��Ϛ��,sb�dM��B��GT���svp�Q\���^W�C[�/vNs1�rJ��(��+�s�;��2�DzzYc�Ǯ�}�ii����������n������?!�Ȁ�?F"�Ҿ4bB�?���4"Y����(XF���!�q Q~L�T�����������?$������䚗��$�$�{�v����뇀os�(�Ǟ?���ʕo�
��rQ+P��Z|��I��������!����A�Qs�� �����a��b������@�!�K���������Lܷ��Di+��������E����cA��s���%�F�-�7�R�G�'�wI����L�}�����~Oi?�uy?��dN�VN���w�͊b[�;�®W��u��2Ƞ]���ёȤ�(jE����5�fjUfe�*�+"#��GYg�s�^Gl0{���r��⪏��9=4�5�t]L�捲�b��Ӵu��]��C_���dê9=�\Q��W&���~�a?�θ��	g��X�rر)��I�a"U��X�:��sq����<_��&r܏uf�iݛI>�Ǯ;���1c�����(Fih?t��XG��Y�Zw�ca�n��y�Mn���൦�J!Q]no�hp�{���]Q�G������L�A�O��N�]��XŬD:���+�1S�(W�jK��.XVq�P	�J���Z��Y|�~���������=�����n�EJm{#�X�ƦY>��0��qW�������2����%U-ȷ���Z����~��C�0������w��0�Y ��_Mka��B��?o�����1�_l `:�0Ȋ��p������L��>��>��؟+�,��~{�j	�V7�����������6'_�Z���(���u�Ǻ۱�&
ȇ	"���GB�]��:+�ԩ�O��6�&_��?l�'+�u��B�u��:s�</]�b�/����Z�n�}��,���>g�r^-�Й���`��^�G̥p��L����N-��N�ӳ���7h�"��N��/�X���5���p��t�Bx���`�l|Y�Q���ȷY6n^�}Vߏ�-kM�c��Z�)[b�x�6��L�]���n!7�������U�09�/�l[�7�Y�gH���4���x�ʐ9(W1��Uw���8#�a����J�\�G�ԽS	Ú��ǈߧ�U��#�7�eA��������L�E�����?��+���O�!K��D����m�'C@�w&��O����O�����o��?׀�@!��c�"�?��燌���
�B��7�o�n������o���o����-����_y�%����������?����w������M�?��?���'��3A^����}� �������o�?`����'��/D� ��ϝ��;����Y� ��9!+��s������� ����(�����B�G&�S�AQH������_!��r�� ���!������C�����	������`��_��|!������
��0��
����
���?$���� ������!���;�0��	���cA�΀����_!����� �_�����y��?���������\B�a4���<���8��60 ���?��+�W�������&p���*��T�F���a���.�J�2�j�:I릩��dEXc*4FS�÷����(�W����������7�'IXTj
�k�/5XK`�\[�N;i�&k��Ͽ���'a�����M�]�>�+X];��9�Z��~�`jj�p��?���m���M��Gm��v���e�����]X�K�5�፥Bb��
7�PZ{��Y�Ѹ�I�2����ZU�<�����|��nn*�/�����g~ȫ��60�[����/?��!�'?����|J���[�qQ���/?|���S�6!��A���3Cb�Y�k�L�em�]��G�jo͇���)L��e�;Z��l�Nt]|6r)�#	q��æR�=�iTtt�4�KE�Dju���r�R���$�R`�->T����ע��sB����>���ب#"��r�A��A������i�4`�(�����W�A�e�/��=��G���XQ ���Ufy�H7d�N�����>^b�����ښ�Lr��ېףm,&�\{;��)���Et�ۍ�v�j�eW�fe���iyf���	1s���[��H��0s{ML��F]�����հyz��\iun�fɋ:����_��l���Y����k��D��ן��9��Ǎ�{���Zpt)"��D����mA��������C^i>9�|"�,Ξ�gx8ޗt�}0k�Juk�m]�>g�֑[��H�Y���alr_L���c�NHM�i:���vG�t~x��E�8�Oy���� ٣�������v��QaR�O��x{���;�_�Ȍ�_^����>! �����v��)�����Z�w<8����s��N���d�����"�y��#��?w�'��@�o&(��d�Ȋ����c���d��G�|\B��w�A�e���� �+ �l�W���rCa���������_�?2��?�i�����C����(t�7=uf0���~S�������c��R�Sϵia�m����ڏ�Ð�R���~ _Q�;ks�k�o�Z�{�@���_q�a�ϝq���i�V�u�g��>R�{���\�\��u1Y�7ʎ��N��i�w5C})������<sE�rd_��e�ȷ��^�~�;u��&�]�cQ�aǦT�'e��Ti�ce�x����֞��|}f����_֙�uo&i�����Fƌ!׳.��,���~�Ǳ�4��������~��Q�������kM�B������$3��q
��`�?7��^-�w[<" �l�W�����P$�~	� �����/��3������W��?	�?9!w��q��!��c�B�?������#` �Q����s×��z=�������fÎؑ�IՉұF��������>�ǒu��tw�����Z��G5 ��j ��p'����yM���U���(�le1�ö��;��Ҙ��QD��*^?i�p`�+%t�ب�qw��UM�Z��k ����  i�� b6��5mn�vM��>.��z�ZچD{
��1��(�bX;x�V����Qa��Hñ҈ܡ؃*�V:j�!ah4]����Ě���a�7������e���߇E��n�������������c�?�����j�1MZ��ZU5�L#L
�hR�)�$�Z3(\71��L�����Z�!�4�>|��"����?!�?|��?Ĝ:�W�Z�Ϝ����GxG�W��0�-]�\��<�����ʧ�@�����*����h��֛"�)9�}�����a���C�W�qO���$�����g�i,�����G3X��kQ���?�C���T���(B��_~(�C�Onȝ�_L�����!Q���/?|��ϟ�7S{%j=I��%���5�NW\�vZ��!�s��b'���=�O�n<�����fk����VsJ!~t
j�U&�� F������J+�#�J�Nz>@{�m��x���G�}-�����Q������{���� p�(D�������/����/�����h�|P�GQ�9�K�o��?����Z���S��3Q�����x�y7)�{��R�=�߷�  ׅ ^� ��V�W7�T�_��/+fv���^���-�ZO�SY�}��2щ���`d���R���3����*Z�.ʝ]�۬xn}�T�!���T6n�_t�|�r3�s\�`�tL0���X��6�y� r�`��y"�~�7�jU򢱦T���#�5��(��4%��#����O�b+���z1S6�C}*��r�þ�G��|f�x�i�Z�����%�g&�ٳ��c�����92��lu�B�>Z�z-j�����Pl��XX��xN�ʼ�����{G[m�l�O�����/�?F&���'H�B�g�Kwn^)�gjd�޽t�<}��?�T7aԣ����r�ϋ��;j��soZG.�E��t��`k:�Ŀ�r�� %:a��v����l�u�����u����;�����z��������_6���O�_6&�����\/]w�l)������?}J"�y�Sh������Nџ?������������㡚��pt���+�NF%#���K~�xQI�l�'�U�e���FTzg��H���"�(�� 0�#�N`��68!uy��O?���/K��Ou����;l�v�^�_��~����?���ϒ/�W�Y�����ෟ><��LH!}�/J��ۃ�O�y:���r{��޽_z�L�3V��1�A�q�`c,-#(]�R�-=?!�a��������Rl'��=���&���C;�����(}J��;��m�;���5H?�ۻ��b��������	7�������.$y��^h�r��5z�7� {��:P�|=��_N�n[����QXB���k�ܨ�����+��#��b�����%%-��&�>��w�O����=A�o{|�#��sGusi�>L����矔��W5�*��w���ҕ���'���!�    ���a � 