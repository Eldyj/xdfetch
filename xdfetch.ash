#!/bin/ash

downcase() {
	echo "${1}" |
	tr '[:upper:]' '[:lower:]';
}

trim() {
	tmp="$(tr -s '[:space:]')";
	case "${tmp:0:1}" in
		' '|"\n"|"\t") {
			tmp="${tmp:1}";
		};;
	esac;

	case "${tmp:${#tmp}-1:1}" in
		' '|"\n"|"\t") {
			tmp="${tmp:0:-1}";
		};;
	esac;

	echo "${tmp}";
}

gl_file() {
	head -n ${1} ${2} |
	tail -n1;
}

if [ -z "${info_align}" ]; then {
	info_align="left";
}; fi;

add_spaces() {
	r="${1}";

	case "${info_align}" in
		"left") {
			while [ "${#r}" -lt "${2}" ]; do {
				r="${r} ";
			}; done;
		};;

		"right") {
			while [ "${#r}" -lt "${2}" ]; do {
				r=" ${r}";
			}; done;
		};;

		*) {
			echo -e "\033[31mERR:\033[0m invalid info_align value: ${}";
		};;
	esac;

	echo "${r}";
}

fmo_init() {
	if [ -z "${fmo}" ]; then {
		fmo="$(
			free -h |
			grep Mem
		)";
	}; fi;
}

umv_init() {
	if [ -z "${umv}" ]; then {
		umv="`uname -v`";
		umvdc="`downcase "${umv}"`";
	}; fi;
}

distro() {
	if [ -z "${distro}" ]; then {
		umv_init;

		distro='N/a';
		for dn in 'alpine' 'arch' 'void' 'debian' 'debian' 'ubuntu'; do {
			if [ -n "`echo ${umvdc} | grep ${dn}`" ]; then {
				distro="${dn}";
				break;
			}; fi;
		}; done;
	}; fi;

	echo "${distro}";
}

memory_capacity() {
	if [ -z "${mem_cap}" ]; then {
		fmo_init;

		mem_cap="$(
			echo "${fmo}" |
			awk '{ print $2 }'
		)";
	}; fi;

	echo "${mem_cap}";
}

memory_usage() {
	if [ -z "${mem_use}" ]; then {
		fmo_init;

		mem_use="$(
			echo "${fmo}" |
			awk '{ print $3 }'
		)";
	}; fi

	echo "${mem_use}";
}

disk_usage() {
	if [ -z "${disk_use}" ]; then {
		disk_use="$(
			du -shb / |
			awk '{ print $1 }'
		)";
	}; fi;

	echo "${disk_use}";
}

disk_capacity() {
	if [ -z "${disk_cap}" ]; then {
		disk_cap="$(
			df -kh / |
			tail -n1 |
			awk '{ print $2 }'
		)";
	}; fi;

	echo "${disk_cap}";
}

cpu_model() {
	if [ -z "${cpu_mod}" ]; then {
		cpu_mod="$(
			grep 'model name' /proc/cpuinfo |
			sed 's/model name//'            |
			sed "s/\t//"                    |
			sed 's/: //'
		)";
	}; fi;

	echo "${cpu_mod}";
}

packages_installed_marked() {
	if [ -z "${pkgsm}" ]; then {
		case "`package_manager`" in
			'apk') {
				pkgsm="$(
					wc -l /etc/apk/world |
					awk '{ print $1 }'
				)";
			};;

			'pacman') {
				pkgsm="`pacman -Qsq`";
			};;

			'xbps') {
				pkgsm='todo!';
			};;

			'apt') {
				pkgsm='todo!';
			};;

			'/usr/bin') {
				pkgsm="$(
					ls -l /usr/bin |
					wc -l
				)";
			};;
		esac;
	}; fi;

	echo "${pkgsm}";
}

packages_installed() {
	if [ -z "${pkgs}" ]; then {
		case "`package_manager`" in
			'apk') {
				pkgs="$(
					apk info |
					wc -l
				)";
			};;

			'pacman') {
				pkgs="$(
					pacmam -Qq |
					wc -l
				)";
			};;

			'xbps') {
				pkgs='todo!';
			};;

			'apt') {
				pkgs="$(
					apt list --installed |
					wc -l
				)";
			};;

			'/usr/bin') {
				pkgs="$(
					ls -l /usr/bin |
					wc -l
				)";
			};;
		esac;
	}; fi;

	echo "${pkgs}";
}

package_manager() {
	if [ -z "${pkgm}" ]; then {
		case "`distro`" in
			'alpine') {
				pkgm='apk';
			};;

			'arch') {
				pkgm='pacman';
			};;

			'void') {
				pkgm='xbps';
			};;

			'debian'|'ubuntu') {
				pkgm='apt';
			};;

			*) {
				pkgm='/usr/bin';
			};;
		esac;
	}; fi;

	echo "${pkgm}";
}

kernel_version() {
	if [ -z "${kernel}" ]; then {
		kernel="`uname -r`";
	}; fi;

	echo "${kernel}";
}

user() {
	echo "${USER}";
}

host() {
	echo "${HOSTNAME}";
}

session_type() {
	if [ -z "${session_type}" ]; then {
		if [ -z "${XDG_SESSION_TYPE}" ]; then {
			session_type="tty?";
		}; else {
			session_type="${XDG_SESSION_TYPE}";
		}; fi;
	}; fi;

	echo "${session_type}";
}

since_uptime() {
	if [ -z "${uptime}" ]; then {
		st="$(date -d "$(uptime -s)" +%s)";
		nt="$(date +%s)";
		dt="$((${nt} - ${st}))";

		d="$((${dt} / (24 * 3600)))";
		dt="$((${dt} % (24 * 3600)))";
		h="$((${dt} / (3600)))";
		dt="$((${dt} % (3600)))";
		m="$((${dt} / (60)))";
		s="$((${dt} % (60)))";

		if [ "${d}" != 0 ]; then {
			uptime="${d} days";
		}; elif [ "${h}" != 0 ]; then {
			uptime="${h} hours";
		}; elif [ "${m}" != 0 ]; then {
			uptime="${m} minutes";
		}; else {
			uptime="${s} secconds";
		}; fi;
	}; fi;

	echo "${uptime}";
}

board() {
	if [ -z "${board}" ]; then {
		board_vendor="$(
			cat ${devinfo}/board_vendor |
			trim
		)";

		board_name="$(
			cat ${devinfo}/board_name |
			trim
		)";

		board_serial="$(
			cat ${devinfo}/board_serial |
			trim
		)";

		board="${board_vendor} ${board_name} (${board_serial})";
	}; fi;

	echo "${board}";
}

model() {
	if [ -z "${model}" ]; then {
		model="$(
			cat ${devinfo}/product_name |
			trim
		)";
	}; fi;

	echo "${model}";
}

gpu_model() {
	if [ -z "${gpu_model}" ]; then {
		gpu_model="$(
			cat ${gpuinfo}/name |
			trim
		)";
	}; fi;

	echo "${gpu_model}";
}

gpu_cores() {
	if [ -z "${gpu_cores}" ]; then {
		gpu_cores="$(
			cat ${gpuinfo}/device/local_cpus |
			trim
		)";
	}; fi;

	echo "${gpu_cores}";
}

init_system() {
	if [ -z "${init_system}" ]; then {
		if [ -n "`which openrc`" ]; then {
			init_system='openrc';
		}; elif [ -n "`which sv`" ]; then {
			init_system='runit';
		}; elif [ -n "`which dinitctl`" ]; then {
			init_system='dinit';
		}; elif [ -n "`which systemctl`" ]; then {
			init_system='no systemd';
		}; else {
			init_system='N/a';
		}; fi;
	}; fi;

	echo "${init_system}";
}

arch() {
	if [ -z "${arch}" ]; then {
		arch="`uname -m`";
	}; fi;

	echo "${arch}";
}

resolution() {
	if [ -z "${resolution}" ]; then {
		resolution="$(
			sed "s/,/x/" "${gpuinfo}/virtual_size"
		)";
	}; fi;

	echo "${resolution}";
}

info() {
	echo "${1}" >> "${h_tmp}";
	echo "${2}" >> "${v_tmp}";
}

info_flush() {
	i=1;
	n="$(
		wc -l "${h_tmp}" |
		awk '{ print $1 }'
	)";

	l="$(
		wc -L "${h_tmp}" |
		awk '{ print $1 }'
	)";

	while [ "${i}" -le "${n}" ]; do {
		value="`gl_file ${i} ${v_tmp}`";
		h_src="`gl_file ${i} ${h_tmp}`";
		header="`add_spaces "${h_src}" "${l}"`";

		echo -e "\033[32m${header}:\033[0m ${value}";
		i="$(( ${i} + 1 ))";
	}; done;

	rm "${v_tmp}" "${h_tmp}";
}

conf_dir="${HOME}/.config/xdfetch";
h_tmp="${conf_dir}/headers.tmp";
v_tmp="${conf_dir}/values.tmp";
devinfo='/sys/devices/virtual/dmi/id';
gpuinfo='/sys/devices/virtual/graphics/fbcon/subsystem/fb0';

source ~/.config/xdfetch/conf.ash;
