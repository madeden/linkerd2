set -eu

install_gcloud() {
    dir="$1"

    export CLOUDSDK_CORE_DISABLE_PROMPTS=1
    if [ -d "$dir/bin" ]; then
        . "$dir/path.bash.inc"
        gcloud components update
    else
        rm -rf "$dir"
        curl https://sdk.cloud.google.com | bash
        . "$dir/path.bash.inc"
    fi
}

set_gcloud_project() {
    # Switches to a new project or exits if called on the same project
    project="$1"
    zone="$2"

    gcloud auth activate-service-account --key-file .gcp.json
    gcloud config set core/project "$project"
    gcloud config set compute/zone "$zone"
}

set_gcloud_cluster() {
    project="$1"
    zone="$2"
    cluster="$3"

    set_gcloud_project "$project" "$zone"
    gcloud config set container/cluster "$cluster"
}

get_k8s_ctx() {
    project="$1"
    zone="$2"
    cluster="$3"

    for c in $(kubectl config get-clusters |sed 1d) ; do
        if [ "$c" = "gke_${project}_${zone}_${cluster}" ]; then
            return 0
        fi
    done

    gcloud container clusters get-credentials -q "$cluster"
}

get_available_k8s_versions() {
    # Returns a ; separated list of valid versions 
    gcloud container get-server-config --zone=us-central1-f --format="value(validMasterVersions:sort=1)"
}

get_default_k8s_version() {
    # Returns the default cluster version available
    gcloud container get-server-config --zone=us-central1-f --format="value(defaultClusterVersion)"
}

create_cluster() {
    cluster="$1"
    k8s_version="$2"
    cluster_size="$3"
    machine_type="$4"

    # Creates a k8s cluster according to a cluster config file
    gcloud container clusters create "${cluster}" \
        --cluster-version "${k8s_version}" \
        --machine-type "${machine_type}" \
        --num-nodes "${cluster_size}" \
        --quiet \
        2>/dev/null

    # This should be a while look instead to make it more robust
    sleep 5

    # Use this cluster & set creds for k8s
    get_k8s_ctx "${project}" "${zone}" "${cluster}"
} 

destroy_cluster() {
    cluster="$1"

    gcloud container clusters delete -q "${cluster}" 2>/dev/null
}